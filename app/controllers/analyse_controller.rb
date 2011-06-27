class AnalyseController < ApplicationController
  http_basic_authenticate_with CFG[:auth] if CFG[:auth]
  before_filter :prepare_selected_paths, :only => [:index, :org]
  rescue_from Exception, :with => :render_simple_error if Rails.env.production?

  def index
    @tags = Trail.tags
    @compare = (params[:compare]||{}).select{|k,v|v.present?}.sort.map(&:last)

    return unless @selected_paths.present? and @compare

    paths = []
    @data = @selected_paths.map do |path|
      paths << path

      scope = Trail.with_paths_in_order(paths, :between => params[:between])
      counts = @compare.map do |tag|
        if tag == 'all'
          scope.count
        else
          scope.where(:tags => tag).count
        end
      end

      [path] + counts
    end
  end

  def org
    @tags = Trail.tags
    return unless @selected_paths.present?

    show_start = params[:show] == 'start'

    # get newest data so we see some change
    @full = 10000
    @data = Trail.with_paths_in_order(@selected_paths, :between => 0).limit(@full).order('id desc').to_a
    @full = @data.size # in case we got less

    # find out where they went to
    @data = @data.map{|t| t.path.split(Trail::SEPARATOR).reject(&:blank?) }
    @data = @data.map do |paths|
      index = paths.index_of_elements_in_order(@selected_paths) or raise('WTF')
      if show_start
        paths[index-1] || 'START'
      else
        paths[index + @selected_paths.size + 1] || 'END'
      end
    end

    @selected_paths.reverse! if show_start

    # targets as % of total
    @data = @data.group_by{|x|x}.map{|k,v| [k, v.size * 100.0 / @full] }.select{|k,v| v >= 0.5}.sort
  end

  # render errors
  def local?
    true
  end

  private

  def prepare_selected_paths
    @selected_paths = (params[:paths]||{}).select{|k,v|v.present?}.sort.map(&:last)
  end
end

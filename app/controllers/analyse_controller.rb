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

    # get newest trails -> current data
    trails = Trail.with_paths_in_order(@selected_paths).limit(10000).order('id desc').to_a
    @full = trails.size

    # find their next/prev path and count em
    found_paths = Hash.new(0)
    trails.each do |trail|
      paths = trail.paths
      index = paths.index_of_elements_in_order(@selected_paths) or raise('WTF')
      found_path = if show_start
        paths[index-1] || 'START'
      else
        paths[index + @selected_paths.size + 1] || 'END'
      end
      found_paths[found_path] += 1
    end

    @selected_paths.reverse! if show_start

    # found_paths as % of total
    @data = found_paths.map{|k,v| [k, v * 100.0 / @full] }.select{|k,v| v >= 0.5}.sort_by(&:last).reverse
  end

  private

  def prepare_selected_paths
    @selected_paths = (params[:paths]||[]).select{|v|v.present?}
  end
end

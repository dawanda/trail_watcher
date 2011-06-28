class AnalyseController < ApplicationController
  http_basic_authenticate_with CFG[:auth] if CFG[:auth]
  before_filter :prepare_selected_paths, :only => [:index, :org]
  rescue_from Exception, :with => :render_simple_error if Rails.env.production?

  def index
    return unless @selected_paths.present? and @compare.present?

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
    return unless @selected_paths.present?

    # get newest trails -> current data
    scope = Trail.with_paths_in_order(@selected_paths).limit(10000).order('id desc')
    scope = scope.where(:tags => @compare.first) if @compare.first
    trails = scope.to_a

    # count path before/after selected_path
    show_start = (params[:show] == 'start')
    found_paths = Hash.new(0)
    trails.each do |trail|
      paths = trail.paths
      index = paths.index_of_elements_in_order(@selected_paths) or raise('WTF')
      found_path = if show_start
        paths[index-1] || 'START'
      else
        paths[index + @selected_paths.size] || 'END'
      end
      found_paths[found_path] += 1
    end

    @selected_paths.reverse! if show_start

    # found_paths as % of total
    @full = trails.size
    @min = 0.5
    @data = found_paths.map{|k,v| [k, v * 100.0 / @full] }.select{|k,v| v >= @min}.sort_by(&:last).reverse
  end

  private

  def prepare_selected_paths
    @tags = Trail.tags
    @selected_paths = (params[:paths]||[]).select{|v|v.present?}
    @compare = (params[:compare]||{}).select{|k,v|v.present?}.sort.map(&:last)
  end
end

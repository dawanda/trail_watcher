class AnalyseController < ApplicationController
  http_basic_authenticate_with CFG[:auth] if CFG[:auth]
  before_filter :prepare_selected_paths, :only => [:index, :org]
  rescue_from Exception, :with => :render_simple_error if Rails.env.production?

  def index
    return unless @selected_paths.present? and @compare.present?

    paths = []

    # via form input => [/cart/show, /cart/address] + [all, login]
    # becomes => [[(/cart/show with all) 100, (/cart/show with login) 50], [(/cart/show;/cart/address with all) 100, (/cart/show;/cart/address with login) 50]
    @data = @selected_paths.map do |path|
      paths << path

      counts = @compare.map do |tag|
        # choose trails betweend from and to
        # find with expanded paths (regexp)
        scope = Trail.between_dates(params[:from], params[:to], :expand_to => true).with_paths_in_order(paths, :between => params[:between])
        scope.with_all_tags(params[:base_tag], tag).count
      end

      [path] + counts
    end
  end

  def org
    return @data = [] unless @selected_paths.present?

    # get newest trails -> current data
    scope = Trail.
      between_dates(params[:from], params[:to], :expand_to => true).
      with_paths_in_order(@selected_paths).
      limit(10000).order('id desc')

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

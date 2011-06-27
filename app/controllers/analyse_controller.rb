class AnalyseController < ApplicationController
  http_basic_authenticate_with CFG[:auth] if CFG[:auth]

  def index
    @tags = Trail.where.distinct(:tags).sort

    all_paths = (params[:paths]||{}).select{|k,v|v.present?}.sort.map(&:last)
    @compare = (params[:compare]||{}).select{|k,v|v.present?}.sort.map(&:last)

    return if all_paths.empty? or @compare.empty?

    paths = []
    @path_trails = all_paths.map do |path|
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
end

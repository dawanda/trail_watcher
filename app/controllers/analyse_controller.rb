class AnalyseController < ApplicationController
  http_basic_authenticate_with CFG[:auth] if CFG[:auth]

  def index
    return if params[:paths].empty?

    paths = []
    @path_trails = params[:paths].map do |k,path|
      next if path.blank?
      paths << path
      [path, Trail.all_in('path' => /;#{paths.join(';.*;')}/).count]
    end.compact
  end
end

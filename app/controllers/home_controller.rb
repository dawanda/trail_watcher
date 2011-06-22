class HomeController < ApplicationController
  def index
    render :text => 'Hello world from Trail Watcher'
  end

  def track
    Trail.track!(options.except(:controller, :action))
  end
end

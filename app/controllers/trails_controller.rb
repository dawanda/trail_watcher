class TrailsController < ApplicationController
  def track
    id = Trail.track!(params.except(:controller, :action).merge(:id => cookies[:trail_watcher_trail_id]))
    cookies[:trail_watcher_trail_id] = {:value => id, :expires => Trail::TIMEOUT.from_now}
    send_file "public/images/pixel.gif", :type => 'image/gif', :disposition => 'inline'
  end
end

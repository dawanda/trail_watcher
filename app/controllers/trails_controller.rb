class TrailsController < ApplicationController
  def track
    if cookies[:trail_watcher_trail_id] or params[:start]
      id = Trail.track!(params.except(:controller, :action).merge(:id => cookies[:trail_watcher_trail_id]))
      cookies[:trail_watcher_trail_id] = {:value => id.to_s, :expires => Trail::TIMEOUT.from_now}
    end
    send_file "public/images/pixel.gif", :type => 'image/gif', :disposition => 'inline'
  end
end

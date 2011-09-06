class TrailsController < ApplicationController
  def track
    if start_or_continue_tracking?
      id = Trail.track!(params.except(:controller, :action).merge(:id => cookies[:trail_watcher_trail_id], :user_id => current_user))
      cookies[:trail_watcher_trail_id] = {:value => id.to_s, :expires => Trail::TIMEOUT.from_now}
    end
    send_file "public/images/pixel.gif", :type => 'image/gif', :disposition => 'inline'
  end

  private

  def start_or_continue_tracking?
    cookies[:trail_watcher_trail_id] or params[:start]
  end

  def current_user
    cookies[:trail_watcher_user_id] ||= {:value => rand(9999999999).to_s, :expires => 1.year.from_now}
    cookies[:trail_watcher_user_id]
  end
end

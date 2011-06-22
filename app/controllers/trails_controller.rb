class TrailsController < ApplicationController
  def track
    Trail.track!(params.except(:controller, :action))
    send_file "public/images/pixel.gif", :type => 'image/gif', :disposition => 'inline'
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_simple_error(e)
    render :text => "#{e.message} -- #{e.class}<br/>#{e.backtrace.join("<br/>")}"
  end
end

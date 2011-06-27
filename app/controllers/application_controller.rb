class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_simple_error(exception)
    render :text => "#{exception.inspect}<br/>#{exception.backtrace.join("<br/>")}"
  end
end

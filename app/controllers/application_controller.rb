class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all

  before_filter :get_bitcoin_client,
    :authenticate,
    :authorize,
    :set_time_zone,
    :remove_params

  def authenticate
    if session[:current_user_id]
      @current_user = User.find session[:current_user_id]
    end
  end

  def authorize
    unless @current_user
      deny_request!
    end
  end

  def deny_request!
    render :template => 'sessions/forbidden',
      :status => :forbidden
  end

  def get_bitcoin_client
    @bitcoin = Bitcoin::Client.new
  end

  def set_time_zone
    if @current_user and !@current_user.time_zone.blank?
      Time.zone = ActiveSupport::TimeZone[@current_user.time_zone]
    end
  end

  def remove_params
    params.delete :skip_captcha
    params.delete :skip_password
  end
end

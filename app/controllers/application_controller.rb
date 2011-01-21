class ApplicationController < ActionController::Base
  # Maximum age for an API authentication token is 30 minutes
  TOKEN_MAX_AGE = 60 * 30

  protect_from_forgery

  helper :all

  before_filter :get_bitcoin_client,
    :move_xml_params,
    :authenticate,
    :authorize,
    :set_time_zone,
    :remove_params,
    :set_locale

  def authenticate
    current_user_id = (session[:current_user_id] or api_authentication)

    if current_user_id
      session[:current_user_id] = current_user_id
      @current_user = User.find(current_user_id)
    end
  end

  def authorize
    unless @current_user
      deny_request!
    end
  end

  def deny_request!
    session[:original_request_path] = request.url if request.get?

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

  # Changes the locale if *locale* (en|fr|...) is passed as GET parameter
  def set_locale
    locale = params[:locale] or session[:locale]
    locale = locale.to_sym if locale

    if locale and I18n.available_locales.include?(locale)
      I18n.locale = locale
      session[:locale] = locale
    end
  end

  def api_authentication
    if params[:authentication] and %w{account token timestamp}.all? { |i| params[:authentication][i] }
      token_age = (Time.now.to_i - Time.at(params[:authentication][:timestamp].to_i).to_i)
      user = User.find_by_account(params[:authentication][:account])

      if (token_age >= 0) and (token_age <= TOKEN_MAX_AGE) and user
        user.check_token(params[:authentication][:token], params[:authentication][:timestamp]) ? user.id : nil
      end
    end
  end

  # This method is used to work around the fact that there is only
  # one allowed root node in a well formed XML document, we remove 
  # the root node so we get to pretend that XML === JSON
  def move_xml_params
    if request.content_type =~ /xml/
      params.merge! params.delete(:api)
    end
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all
  
  layout :pick_layout

  before_filter :authenticate_user!,
    :redirect_iphone,
    :move_xml_params,
    :set_locale,
    :set_time_zone,
    :get_announcements

  def set_time_zone
    if current_user and !current_user.time_zone.blank?
      Time.zone = ActiveSupport::TimeZone[current_user.time_zone]
    end
  end

  # Sets the locale according to the first subdomain or redirects to a localized
  # version of the requested URL
  def set_locale
    locale = I18n.default_locale
    
    if I18n.available_locales.map(&:to_s).include?(request.subdomains.first)
      locale = request.subdomains.first
    end

    I18n.locale = locale.to_sym
  end

  # This method is used to work around the fact that there is only
  # one allowed root node in a well formed XML document, we remove
  # the root node so we get to pretend that XML === JSON
  def move_xml_params
    if request.content_type =~ /xml/
      params.merge! params.delete(:api)
    end
  end

  # Redirects users to their account page after sign-in
  def after_sign_in_path_for(resource)
    session[:user_return_to] or account_path
  end

  def get_announcements
    if params[:action] == 'welcome' || (params[:controller] == "accounts" && params[:action] == "show")
      @announcements = Announcement.active.all
    end
  end
  
  # Picks the correct layout for a given user agent
  def pick_layout
      if iphone?
      "iphone"
    else
      "desktop"
    end
  end
  
  # Redirects iPhones to the sign-in page
  # (ugly hack, should be in config/routes.rb, but a bug in Devise prevents constraint-scoped root paths)
  def redirect_iphone
    if iphone? and params[:controller] == 'informations' and params[:action] == 'welcome'
      redirect_to new_user_session_path
    end
  end
  
  def iphone?
    request.env['HTTP_USER_AGENT'] =~ /iPhone/
  end
end

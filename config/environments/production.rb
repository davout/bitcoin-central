BitcoinBank::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.force_ssl = true
  
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = {
    :host => "bitcoin-central.net"
  }
  
  config.middleware.use ::ExceptionNotifier,
    :email_prefix => "[BC Exception] ",	 	
    :sender_address => %w{no-reply@bitcoin-central.net},	 
    :exception_recipients => %w{support@bitcoin-central.net}
  
  # Used to broadcast invoices public URLs
  config.base_url = "https://bitcoin-central.net/"
  
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.serve_static_assets = false
end

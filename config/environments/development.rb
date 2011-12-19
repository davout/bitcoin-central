BitcoinBank::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true
  
  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Uncomment this to test e-mails in development mode
   config.action_mailer.delivery_method = :sendmail

  # Comment this line if testing e-mails in development mode
  config.action_mailer.delivery_method = :test

  config.action_mailer.default_url_options = {
    :host => "development.bitcoin-central.net"
  }

  config.assets.debug = true

  # Used to broadcast invoices public URLs
  config.base_url = "http://lvh.me:3000/"
end


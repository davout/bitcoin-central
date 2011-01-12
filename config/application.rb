require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module BitcoinBank
  class Application < Rails::Application
    config.i18n.default_locale = :en
    
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.action_dispatch.session_store = :active_record_store

    # Use jQuery instead of Prototype
    config.action_view.javascript_expansions[:defaults] = %w(jquery jquery-ui rails)

    config.autoload_paths << File.join(config.root, "lib")
    config.autoload_paths << File.join(config.root, "lib", "bitcoin")
    config.autoload_paths << File.join(config.root, "lib", "validators")

    config.after_initialize do
      config.middleware.use ::ExceptionNotifier,
        :email_prefix => "Exception : ",
        :sender_address => %w{Bitcoin-Central <no-reply@bitcoin-central.net>},
        :exception_recipients => %w{support@bitcoin-central.net dm.francois@gmail.com}
    end
  end
end

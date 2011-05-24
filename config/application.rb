require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

module BitcoinBank
  class Application < Rails::Application
    I18n.const_set :Locales, {
      :en => "English",
      :de => "Deutsch",
      :it => "Italiano",
      :fr => "Français"
    }

    config.i18n.default_locale = :en

    # See config/initializers/locales.rb
    config.i18n.available_locales = I18n::Locales.keys

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]


    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.action_dispatch.session_store = :active_record_store

    # Use jQuery instead of Prototype
    config.action_view.javascript_expansions[:defaults] = %w(jquery
      jquery-ui rails jqplot jqplot.dateAxisRenderer jqplot.highlighter excanvas)

    config.autoload_paths << File.join(config.root, "lib")
    config.autoload_paths << File.join(config.root, "lib", "bitcoin")
    config.autoload_paths << File.join(config.root, "lib", "validators")

    config.after_initialize do
      config.middleware.use ::ExceptionNotifier,
        :email_prefix => "[BC Exception] : ",
        :sender_address => %w{Bitcoin-Central <no-reply@bitcoin-central.net>},
        :exception_recipients => %w{support@bitcoin-central.net}
    end
  end
end

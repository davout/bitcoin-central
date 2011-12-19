# -*- coding: utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development, test)))
  Bundler.require(:default, Rails.env)
end

module BitcoinBank
  class Application < Rails::Application
    I18n.const_set :Locales, {
      :en => "English",
      :fr => "Français"
    }

    config.i18n.default_locale = :en

    config.i18n.available_locales = I18n::Locales.keys

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml')]


    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.action_dispatch.session_store = :active_record_store

    config.autoload_paths << File.join(config.root, "lib")
    config.autoload_paths << File.join(config.root, "lib", "bitcoin")
    config.autoload_paths << File.join(config.root, "lib", "validators")

    config.assets.enabled = true
    
    Haml::Template.options[:ugly] = true
  end
end

domain = Rails.configuration.base_url.split(":\/\/")[1].gsub(/(\:\d+)?\/?/, "")
BitcoinBank::Application.config.session_store :active_record_store, :key => "bc-session", :domain => domain

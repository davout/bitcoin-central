require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    class GaOtpAuthenticatable < ::Devise::Strategies::DatabaseAuthenticatable
      def authenticate!
        resource = mapping.to.find_for_database_authentication(authentication_hash)
        ga_otp = params[scope][:ga_otp]

        if resource && resource.require_ga_otp? && !resource.valid_ga_otp?(ga_otp)
          fail!(:invalid_ga_otp)
        end
      end
    end
  end
end

Warden::Strategies.add(:ga_otp_authenticatable, Devise::Strategies::GaOtpAuthenticatable)


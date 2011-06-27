require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    class OtpCheckable < ::Devise::Strategies::DatabaseAuthenticatable
      def authenticate!
        resource = mapping.to.find_for_database_authentication(authentication_hash)
        otp = params[scope][:otp]

        if resource && resource.require_otp? && !resource.valid_otp?(otp)
          fail!(:invalid_otp)
        end
      end
    end
  end
end

Warden::Strategies.add(:otp_checkable, Devise::Strategies::OtpCheckable)


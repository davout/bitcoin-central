require 'devise/strategies/database_authenticatable'

module Devise
  module Strategies
    class YkOtpAuthenticatable < ::Devise::Strategies::DatabaseAuthenticatable
      def authenticate!
        resource = mapping.to.find_for_database_authentication(authentication_hash)
        yk_otp = params[scope][:yk_otp]

        if resource && resource.require_yk_otp? && resource.valid_yk_otp?(yk_otp)
          fail!(:invalid_yk_otp)
        end
      end
    end
  end
end

Warden::Strategies.add(:yk_otp_authenticatable, Devise::Strategies::YkOtpAuthenticatable)


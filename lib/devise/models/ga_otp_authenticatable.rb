module Devise
  module Models
    module GaOtpAuthenticatable
      extend ActiveSupport::Concern

      included do
        before_create :generate_ga_otp_secret
        attr_accessor :ga_otp
      end

      def ga_provisioning_uri
        ROTP::TOTP.new(ga_otp_secret).provisioning_uri(to_label)
      end

      def generate_ga_otp_secret
        self.ga_otp_secret = ROTP::Base32.random_base32
      end

      def valid_ga_otp?(ga_otp)
        !ga_otp.blank? && ga_otp.match(/[0-9]{6}/) && ROTP::TOTP.new(ga_otp_secret).verify(ga_otp.to_i)
      end
    end
  end
end

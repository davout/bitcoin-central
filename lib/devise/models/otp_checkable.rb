module Devise
  module Models
    module OtpCheckable
      extend ActiveSupport::Concern

      included do
        before_create :generate_otp_secret
        attr_accessor :otp
      end

      def provisioning_uri
        ROTP::TOTP.new(otp_secret).provisioning_uri(to_label)
      end

      def generate_otp_secret
        self.otp_secret = ROTP::Base32.random_base32
      end

      def valid_otp?(otp)
        otp.match(/[0-9]{6}/) && ROTP::TOTP.new(otp_secret).verify(otp.to_i)
      end
    end
  end
end

module Devise
  module Models
    module YkOtpAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_accessor :yk_otp
      end

      def valid_yk_otp?(yk_otp)
        yubikeys.any? { |y| y.valid_otp?(yk_otp) }
      end
    end
  end
end

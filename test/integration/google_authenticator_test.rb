require 'test_helper'

class GoogleAuthenticatorTest < ActionDispatch::IntegrationTest
  test "should not be able to authenticate without otp" do
    u = Factory.build(:user)
    u.require_ga_otp = true
    u.generate_ga_otp_secret
    u.save!

    # Authenticating without OTP will fail
    post user_session_path, :user => {
      :name => u.name,
      :password => u.password
    }

    assert_response :success

    # Wrong OTP should fail too
    post user_session_path, :user => {
      :name => u.name,
      :password => u.password,
      :ga_otp => "424242"
    }

    assert_response :success

    # Correct OTP should work
    post user_session_path, :user => {
      :name => u.name,
      :password => u.password,
      :ga_otp => ROTP::TOTP.new(u.ga_otp_secret).now
    }

    assert_response :redirect
    assert_redirected_to account_path
  end
end

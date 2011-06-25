require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should correctly report user balance" do
    assert_equal 0.0, users(:trader1).balance(:btc)
    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)
    assert_equal 0.0, users(:trader2).balance(:lrusd)
  end

  test "should generate otp secret on creation" do
    user = User.create! do |u|
      u.email = "test@random.com"
      u.password = "abc123456"
      u.skip_captcha = true
    end

    assert !user.otp_secret.blank?, "A random OTP secret should have been generated"
  end

  test "should return correct provisioning URI" do
    user = User.create! do |u|
      u.email = "test@random.com"
      u.password = "abc123456"
      u.skip_captcha = true
    end

    assert_equal "otpauth://totp/#{URI.encode(user.account)}?secret=#{user.otp_secret}",
      user.provisioning_uri
  end
end

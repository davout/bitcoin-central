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

  test "should refresh addy only every hour" do
    # TODO : stub address generation call
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo", "bar")

    u = users(:trader1)

    address1 = u.bitcoin_address
    u.generate_new_address
    address2 = u.bitcoin_address

    assert_equal address1, address2

    u.last_address_refresh = DateTime.now.advance(:days => -1)

    u.generate_new_address
    address3 = u.bitcoin_address

    assert_not_equal address2, address3
  end
end

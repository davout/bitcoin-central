require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should create user" do
    User.create! do |u|
      u.email = "email@domain.tld"
      u.password = "123456"
      u.password_confirmation = "123456"
      u.skip_captcha = true
    end
  end
  
  test "should correctly report user balance" do
    u = Factory(:user)
    
    assert u.balance(:btc).zero?
    
    o = Factory(:operation)
    o.account_operations << Factory.build(:account_operation, :currency => "BTC", :amount => BigDecimal("10.0"), :account => u)
    o.account_operations << Factory.build(:account_operation, :currency => "BTC", :amount => BigDecimal("-10.0"))
    
    assert o.save    
    assert_equal BigDecimal("10.0"), u.balance(:btc)
  end

  test "should generate otp secret on creation" do
    user = Factory(:user)
    assert !user.ga_otp_secret.blank?, "A random OTP secret should have been generated"
  end

  test "should return correct provisioning URI" do
    user = Factory.build(:user)

    assert_equal "otpauth://totp/#{URI.encode(user.name)}?secret=#{user.ga_otp_secret}",
      user.ga_provisioning_uri
  end

  test "should refresh addy only every hour" do
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo", "bar")

    u = Factory.build(:user, :bitcoin_address => nil)

    address1 = u.bitcoin_address
    u.generate_new_address
    address2 = u.reload.bitcoin_address

    assert_equal address1, address2

    u.last_address_refresh = DateTime.now.advance(:days => -1)

    u.generate_new_address
    address3 = u.reload.bitcoin_address

    assert_not_equal address2, address3
  end
end

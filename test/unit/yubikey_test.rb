require 'test_helper'

class YubikeyTest < ActiveSupport::TestCase
  test "should initialize key properly from otp" do
    Yubico::Client.instance.expects(:verify_otp).with("cccccccnccfudvebtledcgvnikvbijhhgjutverdlurv").returns(true)
    
    Yubikey.create! do |y|
      y.otp = "cccccccnccfudvebtledcgvnikvbijhhgjutverdlurv"
      y.user = Factory(:user)
    end
  end
end

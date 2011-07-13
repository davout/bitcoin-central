require 'test_helper'

class YubikeyAuthTest < ActionDispatch::IntegrationTest
  test "should not be able to authenticate without yubikey" do
    Yubico::Client.instance.stubs(:verify_otp).returns(true)
    u = Factory(:user)
    y = Factory(:yubikey, :user => u)
    
    # First authentication attempt should pass without yubikey
    post user_session_path, :user => {
      :account => u.account,
      :password => u.password
    }

    assert_response :redirect
    assert_redirected_to account_path
    
    get destroy_user_session_path
    assert_response :redirect
    assert_redirected_to root_path
    
    get account_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
    
    u.require_yk_otp = true
    u.save!
    
    # Second one should fail with a yubikey related message
    post user_session_path, :user => {
      :account => u.account,
      :password => u.password
    }
    
    assert_response :success
    
    # Third request with a wrong OTP should fail too
    post user_session_path, :user => {
      :account => u.account,
      :password => u.password,
      :yk_otp => "somewrongotp"
    }
    
    assert_response :success

    # Fourth request with a good OTP should succeed
    Yubico::Client.instance.stubs(:verify_otp).returns(true)
    post user_session_path, :user => {
      :account => u.account,
      :password => u.password,
      :yk_otp => "#{y.key_id}somecorrectotp"
    }
    
    assert_response :redirect
    assert_redirected_to account_path
  end
end

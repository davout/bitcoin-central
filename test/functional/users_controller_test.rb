require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    login_with :trader1
  end

  test "should reset otp token" do
    old_token = users(:trader1).otp_secret

    post :reset_otp_secret
    assert_response :redirect
    assert_redirected_to otp_configuration_user_path

    assert_not_equal old_token, users(:trader1).reload.otp_secret
  end

  test "should show otp configuration page" do
    get :otp_configuration
    assert_response :success
  end
end

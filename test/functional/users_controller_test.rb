require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    login_with :trader1
  end

  test "should render account edition form" do
    get :edit
    assert_response :success
  end

  test "should reset google auth otp" do
    old_token = users(:trader1).ga_otp_secret

    post :reset_ga_otp_secret
    assert_response :redirect
    assert_redirected_to ga_otp_configuration_user_path

    assert_not_equal old_token, users(:trader1).reload.ga_otp_secret
  end

  test "should show google auth otp configuration page" do
    get :ga_otp_configuration
    assert_response :success
  end
end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = login_with(Factory(:user))
  end

  test "should render account edition form" do
    get :edit
    assert_response :success
  end

  test "should reset google auth otp" do
    old_token = @user.ga_otp_secret

    post :reset_ga_otp_secret
    assert_response :redirect
    assert_redirected_to ga_otp_configuration_user_path

    assert_not_equal old_token, @user.reload.ga_otp_secret
  end

  test "should show google auth otp configuration page" do
    get :ga_otp_configuration
    assert_response :success
  end
  
  test "should render account edition form for manager" do
    sign_out(:user)
    get :edit
    assert_response :redirect
    
    manager = Factory(:manager)
    sign_in(:user, manager)
    
    get :edit
    assert_response :success
  end
end

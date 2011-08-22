require 'test_helper'

class Admin::AccountOperationsControllerTest < ActionController::TestCase
  test "one doesn't just walk into admin interface" do
    login_with Factory(:user)
    get :index, :user_id => Factory(:user).id

    assert_response :redirect
    assert_redirected_to root_path
  end

  test "admins get to rob you" do
    login_with Factory(:admin)
    get :index, :user_id => Factory(:user).id
    
    assert_response :success
  end
end

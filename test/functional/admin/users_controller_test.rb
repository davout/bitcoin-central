require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  test "should get users admin" do
    login_with Factory(:admin)
    get :index
    assert_response :success
  end
end

require 'test_helper'

class Admin::TransfersControllerTest < ActionController::TestCase
  test "one doesn't just walk into admin interface" do
    login_with :trader1
    get :index
    assert_response :forbidden
  end

  test "admins get to rob you" do
    login_with :admin
    get :index
    assert_response :success
  end
end

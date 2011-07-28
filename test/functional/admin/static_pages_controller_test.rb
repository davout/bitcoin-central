require 'test_helper'

class Admin::StaticPagesControllerTest < ActionController::TestCase
  test "should show index properly" do
    login_with Factory(:user, :admin => true)
    get :index
    assert_response :success
  end
end

require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should login with email" do
    post :create, :account => "trader1@bitcoin-central.net",
      :password => "pass"

    assert_response :redirect
    assert_redirected_to root_path
    assert_equal session[:current_user_id], users(:trader1).id
  end

  test "should login with account ID" do
    post :create, :account => "BC-T000000",
      :password => "pass"

    assert_response :redirect
    assert_redirected_to root_path
    assert_equal session[:current_user_id], users(:trader1).id
  end

  test "should logout properly" do
    login_with(:trader1)
    assert_equal session[:current_user_id], users(:trader1).id

    delete :destroy
    assert_nil session[:current_user_id]
  end
end

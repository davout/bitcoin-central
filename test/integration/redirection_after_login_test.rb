require 'test_helper'

class RedirectionAfterLoginTest < ActionDispatch::IntegrationTest
  test "should redirect to originally requested page after login" do
    user = Factory(:user)
    
    post user_session_path, :user => {
      :name => user.email,
      :password => user.password
    }

    assert_response :redirect
    assert_redirected_to account_path

    # The GET is Devise's :X
    get destroy_user_session_path

    get account_trade_orders_path
    assert_response :redirect
    assert_redirected_to new_user_session_path

    follow_redirect!
    assert_template 'devise/sessions/new'

    post user_session_path, :user => {
      :name => user.email,
      :password => user.password
    }

    assert_response :redirect
    assert_redirected_to account_trade_orders_path
  end
end

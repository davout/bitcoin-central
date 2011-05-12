require 'test_helper'

class RedirectionAfterLoginTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should redirect to originally requested page after login" do
    post user_session_path, :user => {
      :account => "trader1@bitcoin-central.net",
      :password => "password"
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
      :account => "trader1@bitcoin-central.net",
      :password => "password"
    }

    assert_response :redirect
    assert_redirected_to account_trade_orders_path
  end
end

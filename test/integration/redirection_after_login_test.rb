require 'test_helper'

class RedirectionAfterLoginTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should redirect to originally requested page after login" do
    post session_path, :account => "trader1@bitcoin-central.net",
      :password => "pass"

    assert_response :redirect
    assert_redirected_to account_path

    delete session_path

    get account_trade_orders_path
    assert_response :forbidden
    assert_template "sessions/forbidden"

    post session_path, :account => "trader1@bitcoin-central.net",
      :password => "pass"

    assert_response :redirect
    assert_redirected_to account_trade_orders_path
  end
end

require 'test_helper'

class TradesControllerTest < ActionController::TestCase
  test "should render ticker" do
    assert session[:current_user_id].nil?, "We should not be logged-in"

    [:json, :xml].each do |f|
      get :ticker, :format => f
      assert_response :success
    end
  end
end

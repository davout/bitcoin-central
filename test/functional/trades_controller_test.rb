require 'test_helper'

class TradesControllerTest < ActionController::TestCase
  test "should render ticker" do
    assert session[:current_user_id].nil?, "We should not be logged-in"

    [:json, :xml].each do |f|
      get :ticker, :format => f
      assert_response :success
    end
  end
  
  test "should render trades list" do
    t1 = Factory(:user)
    t2 = Factory(:user)
    
    add_money(t1, 1000, :btc)
    add_money(t2, 1000, :eur)
    
    Factory(:limit_order,
      :amount => 1,
      :category => "sell",
      :ppc => 1,
      :user => t1,
      :currency => "EUR"
    )
    
    t = Factory(:market_order,
      :amount => 1,
      :category => "buy",
      :user => t2,
      :currency => "EUR"
    )  
      
    assert_difference "Trade.count" do
      t.execute!
    end
    
    login_with(Factory(:user))
    get :index
    assert_response :success
  end
end

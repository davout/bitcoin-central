require 'test_helper'

class TradeOrdersControllerTest < ActionController::TestCase
  def setup
    @user = Factory(:user)

    add_money(@user, 25.0, :lrusd)
    add_money(@user, 100.0, :btc)

    LimitOrder.create! do |t|
      t.amount = 1.0
      t.ppc = 1.0
      t.user = @user
      t.currency = "LRUSD"
      t.category = "buy"
    end

    LimitOrder.create! do |t|
      t.amount = 1.0
      t.ppc = 1.0
      t.user = @user
      t.currency = "LRUSD"
      t.category = "sell"
    end
  end

  test "should render index" do
    login_with(@user)
    get :index
    assert_response :success
  end

  test "should render order book" do
    login_with(@user)
    get :book
    assert_response :success
  end

  test "should render book when not logged" do
    sign_out(:user)
    get :book
    assert_response :success
  end

  test "should get order book in json format" do
    sign_out(:user)
    get :book, :format => :json
    assert_response :success
  end

  test "should get order book in XML format" do
    sign_out(:user)
    get :book, :format => :xml
    assert_response :success
  end

  test "should create trade order" do
    login_with(@user)

    post :create, :trade_order => {
      :category => "sell",
      :amount => "1",
      :ppc => "1",
      :currency => "PGAU",
      :type => "limit_order"
    }

    assert_response :redirect
    assert_redirected_to account_trade_orders_path
  end

  test "should activate trade order" do
    trader = Factory(:user)
    login_with(trader)

    add_money(trader, 100.0, :btc)

    t1 = Factory(:limit_order,
         :amount => 100.0,
         :category => "sell",
         :currency => "EUR",
         :ppc      => 1.0,
         :user     => trader
         )

    assert t1.active?

    add_money(trader, -100.0, :btc)

    assert !t1.reload.active?

    add_money(trader, 100.0, :btc)

    assert t1.reload.activable?

    post :activate, :trade_order_id => t1.id

    assert_response :redirect

    assert_redirected_to account_trade_orders_path
  end
end

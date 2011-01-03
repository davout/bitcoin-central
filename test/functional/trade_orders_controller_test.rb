require 'test_helper'

class TradeOrdersControllerTest < ActionController::TestCase
  def setup
    LibertyReserveTransfer.create!(
      :amount => 25.0,
      :user => users(:trader1),
      :currency => "LRUSD",
      :internal => true
    )

    BitcoinTransfer.create(
      :amount => 100.0,
      :user => users(:trader1),
      :currency => "BTC"
    )

    TradeOrder.create!(
      :amount => 1.0,
      :ppc => 1.0,
      :user => users(:trader1),
      :currency => "LRUSD",
      :category => "buy"
    )

    TradeOrder.create!(
      :amount => 1.0,
      :ppc => 1.0,
      :user => users(:trader1),
      :currency => "LRUSD",
      :category => "sell"
    )
  end

  test "should render index" do
    login_with :trader1
    get :index
    assert_response :success
  end

  test "should render order book" do
    login_with :trader1
    get :book
    assert_response :success
  end

  test "should render book when not logged" do
    assert session[:current_user_id].nil?, "we don't want to be logged-in here"
    get :book
    assert_response :success
  end

  test "should get order book in json format" do
    get :book, :format => :json
    assert_response :success
  end
  
  test "should get order book in XML format" do
    get :book, :format => :xml
    assert_response :success
  end
end

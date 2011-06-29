require 'test_helper'

class TradeOrdersControllerTest < ActionController::TestCase
  def setup
    Transfer.create! do |t|
      t.amount = 25.0
      t.user = users(:trader1)
      t.currency = "LRUSD"
    end

    Transfer.create! do |t|
      t.amount = 100.0
      t.user = users(:trader1)
      t.currency = "BTC"
    end

    TradeOrder.create! do |t|
      t.amount = 1.0
      t.ppc = 1.0
      t.user = users(:trader1)
      t.currency = "LRUSD"
      t.category = "buy"
    end

    TradeOrder.create! do |t|
      t.amount = 1.0
      t.ppc = 1.0
      t.user = users(:trader1)
      t.currency = "LRUSD"
      t.category = "sell"
    end
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

  test "should create trade order" do
    flunk
  end
end

require 'test_helper'

class TransfersControllerTest < ActionController::TestCase
  test "should withdraw bitcoins" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :btc)

    Bitcoin::Client.instance.expects(:send_to_address).once.returns("foo")

    assert_difference "BitcoinTransfer.count" do
      assert_difference "user.balance(:btc)", BigDecimal("-500") do
        post :create, :transfer => {
          :currency => "BTC",
          :amount => "500"
        }
      end
    end
  end

  test "should withdraw liberty reserve" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :lrusd)

    LibertyReserve::Client.instance.expects(:transfer).once.returns({ 'TransferResponse' => { 'Receipt' => { 'ReceiptId' => "foo" }}})

    assert_difference "LibertyReserveTransfer.count" do
      assert_difference "user.balance(:lrusd)", BigDecimal("-500") do
        post :create, :transfer => {
          :currency => "LRUSD",
          :amount => "500",
          :lr_account_id => "X321695"
        }
      end
    end
  end

  test "should withdraw with wire transfer" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :eur)

    assert_difference "WireTransfer.count" do
      assert_difference "user.balance(:eur)", BigDecimal("-500") do
        post :create, :transfer => {
          :currency => "EUR",
          :amount => "500"
        }
      end
    end
  end

  test "should show account history page" do
    user = login_with(Factory(:user))
    add_money(user, 25.0, :lrusd)

    get :index
    assert_response :success
  end

  test "should show transfer details" do
    user = login_with(Factory(:user))
    add_money(user, 25.0, :lrusd)

    get :show, :id => user.account_operations.first.id
    assert_response :success
  end
end

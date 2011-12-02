require 'test_helper'

class TransfersControllerTest < ActionController::TestCase
  test "should withdraw bitcoins" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :btc)

    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)    
    Bitcoin::Client.instance.stubs(:send_to_address).returns("foo")
    Bitcoin::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))

    assert_difference "BitcoinTransfer.count" do
      assert_difference "user.balance(:btc)", BigDecimal("-500") do
        post :create, :transfer => {
          :currency => "BTC",
          :amount => "500",
          :address => "bar"
        }
      end
    end
    
    assert_redirected_to account_transfers_path
  end
  
  test "should reply with json when creating through api" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :btc)

    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)    
    Bitcoin::Client.instance.stubs(:send_to_address).returns("foo")
    Bitcoin::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))

    post :create, :transfer => { :currency => "BTC", :amount => "500", :address => "bar" },
      :format => :json
    
    assert JSON.parse(response.body)["id"]   
  end

  test "should withdraw liberty reserve" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :lrusd)

    LibertyReserve::Client.instance.stubs(:transfer).returns({ 'TransferResponse' => { 'Receipt' => { 'ReceiptId' => "foo" }}})
    LibertyReserve::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))

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
        assert_difference "user.bank_accounts.count" do
          post :create, :transfer => {
            :currency => "EUR",
            :amount => "500",
            :bank_account_attributes => {
              :iban => "FR1420041010050500013M02606",
              :bic => "SOGEFRPP",
              :account_holder => "Dave"
            }
          }

          assert_response :redirect
          assert_redirected_to account_transfers_path
        end
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
    assert_nil response.body =~ /Status/
  end
  
  test "should show transfer details with status field if relevant" do
    user = login_with(Factory(:user))
    add_money(user, 1000.0, :eur)
    w = Factory(:wire_transfer, :account => user, :bank_account => Factory(:bank_account, :user => user))

    get :show, :id => w.id
    assert_response :success
    assert_match  /Status/, response.body
  end

  test "transaction should get rolled back if transfer is not valid" do
    user = login_with(Factory(:user))

    assert_no_difference 'Operation.count' do
      post :create, :transfer => {
        :amount => "500",
        :currency => "EUR",
        :iban => "321654",
        :bic => "FOO",
        :full_name_and_address => "Dave"
      }
    end
  end

  test "should inform about processed transfer status" do
    user = login_with(Factory(:user))
    add_money(user, 100, :btc)

    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)
    Bitcoin::Client.instance.stubs(:send_to_address).returns("foo")
    Bitcoin::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))

    assert_difference 'Operation.count' do
      assert_difference 'AccountOperation.count', 2 do
        assert_difference 'BitcoinTransfer.count' do
          post :create, :transfer => {
            :currency => "BTC",
            :amount => "50",
            :address => "foo"
          }

          assert_match /Your successfully withdrew/, flash[:notice]
          assert assigns(:transfer).processed?
        end
      end
    end
  end

  test "should inform about pending transfer status" do
    user = login_with(Factory(:user))
    add_money(user, 100, :btc)
    
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)
    Bitcoin::Client.instance.stubs(:send_to_address).returns("foo")
    Bitcoin::Client.instance.stubs("get_balance").returns(BigDecimal("10"))
    
    assert_difference 'Operation.count' do
      assert_difference 'AccountOperation.count', 2 do
        assert_difference 'BitcoinTransfer.count' do
          post :create, :transfer => {
            :currency => "BTC",
            :amount => "50",
            :address => "foo"
          }
    
          assert_match /Your withdrawal request was successful and will be processed shortly/, flash[:notice]
          assert assigns(:transfer).pending?
        end
      end
    end
  end  
end

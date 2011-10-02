require 'test_helper'

class BitcoinTransferTest < ActiveSupport::TestCase
  test "should execute transfer after creation if sufficient server balance" do
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)
    Bitcoin::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))
    Bitcoin::Client.instance.stubs(:send_to_address).returns("foobar")
    
    u = Factory(:user)
    add_money(u, 1000, :btc)
    b = Factory(:bitcoin_transfer, :amount => -100, :account => u)
    
    assert_equal "foobar", b.bt_tx_id
  end
  
  test "should postpone transfer after creation if insufficient server balance" do
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)
    Bitcoin::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))
    Bitcoin::Client.instance.stubs(:send_to_address).returns("foobar")
    
    u = Factory(:user)
    add_money(u, 1000, :btc)
    b = Factory(:bitcoin_transfer, :amount => -100, :account => u)
    
    assert_equal "foobar", b.bt_tx_id
  end
  
  test "should not consider a btc transfer valid without an address" do
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Util.stubs(:my_bitcoin_address?).returns(false)
    Bitcoin::Client.instance.stubs(:get_balance).returns(BigDecimal("1000"))
    Bitcoin::Client.instance.stubs(:send_to_address).raises(Exception, "This shouldn't be called in this case")
    
    u = Factory(:user)
    add_money(u, 1000, :btc)
    b = Factory.build(:bitcoin_transfer, :amount => -100, :account => u, :address => "")
    
    assert !b.valid?
  end  
  
end

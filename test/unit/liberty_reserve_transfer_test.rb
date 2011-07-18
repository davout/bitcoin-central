require 'test_helper'

class LibertyReserveTransferTest < ActiveSupport::TestCase
  test "fees should be calculated correctly using rounding up" do
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("95.13")), BigDecimal("0.96")
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("133.66")), BigDecimal("1.34")
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("53")), BigDecimal("0.53")
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("50.34")), BigDecimal("0.51")
  end
  
  test "fees should be capped both ways" do
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("800")), BigDecimal("2.99")
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("300")), BigDecimal("2.99")
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("299")), BigDecimal("2.99")
    assert_equal LibertyReserveTransfer.fee_for(BigDecimal("0.5")), BigDecimal("0.01")
  end
  
  test "fees should be calculated only for BigDecimals" do
    assert_raise RuntimeError do
      LibertyReserveTransfer.fee_for(100.0)
    end
    
    assert_raise RuntimeError do
      LibertyReserveTransfer.fee_for(100)
    end
  end
  
  test "rounding amounts on execution" do
    u = Factory(:user)
    
    add_money(u, BigDecimal("25.0"), :lrusd)
    assert_equal BigDecimal("25.0"), u.balance(:lrusd)

    o = Factory(:operation)
    
    LibertyReserve::Client.instance.stubs(:transfer).returns(
      { 'TransferResponse' => {  'Receipt' => { 'ReceiptId' => "foo" } } }
    )

    o.account_operations << LibertyReserveTransfer.new do |t|
      t.amount = BigDecimal("-1.118")
      t.currency = "LRUSD"
      t.account = u
      t.lr_account_id = "bar"
    end
    
    o.account_operations << Factory.build(:account_operation, :amount => BigDecimal("1.11"), :currency => "LRUSD")

    assert o.save    
    assert_equal BigDecimal("23.89"), u.balance(:lrusd)
  end

  test "polling liberty reserve API should result in a transaction being properly created *once*" do
    LibertyReserve::Client.instance.stubs(:get_transaction).returns({
        :currency => "LRUSD",
        :lr_transaction_id => "123456",
        :lr_account_id => "UXXX",
        :lr_merchant_fee => BigDecimal("0.01"),
        :lr_transferred_amount => BigDecimal("1.0"),
        :amount => BigDecimal("0.99"),
        :account => Factory(:user)
      }
    )
    
    assert_difference 'AccountOperation.count', 2 do
      Transfer.create_from_lr_transaction_id("foo")
    end
  end
end

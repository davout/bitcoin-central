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
    assert_equal BigDecimal("25.0"), users(:trader1).balance(:lrusd)

    LibertyReserve::Client.instance.stubs(:transfer).returns(
      { 'TransferResponse' => {  'Receipt' => { 'ReceiptId' => "foo" } } }
    )

    LibertyReserveTransfer.create! do |t|
      t.amount = BigDecimal("-1.118")
      t.currency = "LRUSD"
      t.user = users(:trader1)
      t.lr_account_id = "bar"
    end

    assert_equal BigDecimal("23.89"), users(:trader1).balance(:lrusd)
  end
end

require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  test "transfer should fail with very small amount" do
    t = Factory.build(:transfer) do |t|
      t.amount = 0.0001
      t.currency = "LREUR"
      t.account = Factory(:user)
    end
    
    assert !t.valid?
    assert t.errors[:amount].any? { |e| e =~ /should not be smaller than/ }
  end

  test "should return correct class for transfer" do
    assert_equal Transfer.class_for_transfer(:eur), WireTransfer
    assert_equal Transfer.class_for_transfer(:lrusd), LibertyReserveTransfer
    assert_equal Transfer.class_for_transfer(:lreur), LibertyReserveTransfer
    assert_equal Transfer.class_for_transfer(:btc), BitcoinTransfer

    assert_raise RuntimeError do
      Transfer.class_for_transfer(:bogus)
    end
  end
end

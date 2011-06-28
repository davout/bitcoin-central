require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  test "transfer should update user balance immediately" do
    assert_equal 0, users(:trader1).balance(:lreur)

    Transfer.create! do |t|
      t.amount = 10.0
      t.currency = "LREUR"
      t.user = users(:trader1)
    end
    
    assert_equal 10.0, users(:trader1).balance(:lreur)
  end

  test "transfer should fail with very small amount" do
    t = Transfer.new do |t|
      t.amount = 0.0001
      t.currency = "LREUR"
      t.user = users(:trader1)
    end

    assert !t.valid?
  end

  test "transfer should not allow skip_min_amount to be mass-assigned" do
    # Syntax is important here, if we pass a hash instead of a block the
    # transfer should not be valid since the skip_min_amount attribute
    # should not be assignable through mass-assignment
    t = Transfer.new(
      :amount => 0.0001,
      :currency => "LREUR",
      :skip_min_amount => true
    )

    t.user = users(:trader1)
    
    assert !t.valid?
  end

  test "transfer should allow very small amount with skip_min_amount" do
    t = Transfer.new do |tr|
      tr.amount = 0.0001
      tr.currency = "LREUR"
      tr.user = users(:trader1)
      tr.skip_min_amount = true
    end

    assert t.valid?
  end

  test "polling liberty reserve API should result in a transaction being properly created *once*" do
    LibertyReserve::Client.instance.stubs(:get_transaction).returns({
        :currency => "LRUSD",
        :lr_transaction_id => "123456",
        :lr_account_id => "UXXX",
        :lr_merchant_fee => BigDecimal("0.01"),
        :lr_transferred_amount => BigDecimal("1.0"),
        :amount => BigDecimal("0.99"),
        :user => User.find(:first)
      }
    )

    assert_difference 'Transfer.count' do
      Transfer.create_from_lr_transaction_id("foo")
    end
  end
end

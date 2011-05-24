require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  test "transfer should update user balance immediately" do
    assert_equal 0, users(:trader1).balance(:lreur)

    Transfer.create!(
      :amount => 10.0,
      :user => users(:trader1),
      :currency => "LREUR"
    )

    assert_equal 10.0, users(:trader1).balance(:lreur)
  end

  test "transfer should fail with very small amount" do
    t = Transfer.new(
      :amount => 0.0001,
      :user => users(:trader1),
      :currency => "LREUR"
    )

    assert !t.valid?
  end

  test "transfer should not allow skip_min_amount to be mass-assigned" do
    t = Transfer.new(
      :amount => 0.0001,
      :user => users(:trader1),
      :currency => "LREUR",
      :skip_min_amount => true
    )

    assert !t.valid?
  end

    test "transfer should allow very small amount with skip_min_amount" do
    t = Transfer.new(
      :amount => 0.0001,
      :user => users(:trader1),
      :currency => "LREUR"
    )

    t.skip_min_amount = true

    assert t.valid?
  end
end

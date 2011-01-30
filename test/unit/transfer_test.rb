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
end

require 'test_helper'

class BitcoinTransferTest < ActiveSupport::TestCase
  test "bitcoin transfer creation should refresh user addy" do
    transfer = BitcoinTransfer.new do |t|
      t.amount = 10.0
      t.currency = "BTC"
      t.user = users(:trader1)
    end

    transfer.user.expects(:generate_new_address).at_least_once
    assert transfer.save
  end
end

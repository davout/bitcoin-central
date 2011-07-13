require 'test_helper'

class BitcoinTransferTest < ActiveSupport::TestCase
  test "bitcoin transfer creation should refresh user addy" do
    transfer = BitcoinTransfer.new do |t|
      t.amount = 10.0
      t.currency = "BTC"
      t.account = accounts(:trader1)
    end

    transfer.account.expects(:generate_new_address).at_least_once
    assert transfer.save
  end

  test "transaction sync should handle small txes without problem" do
    tx = {
      "category" => "receive",
      "amount" => 0.00001,
      "confirmations" => 35414,
      "txid" => "0e0e9fec1195132b28662539528e936c981ebd3b0f140d9ad3c65717cf2f329a"
    }  
    
    Bitcoin::Client.instance.
      stubs(:list_transactions).
      returns([tx], [tx])
    
    User.stubs(:all).returns(User.where("id = ?", accounts(:trader1).id))

    assert_difference 'accounts(:trader1).balance(:btc)', 0.00001.to_d do
      assert_difference 'Transfer.count' do
        BitcoinTransfer.synchronize_transactions!
      end
    end

    # It should then not fail when updating the same transaction
    assert_no_difference 'accounts(:trader1).balance(:btc)' do
      assert_no_difference 'Transfer.count' do
        BitcoinTransfer.synchronize_transactions!
      end
    end
  end
end

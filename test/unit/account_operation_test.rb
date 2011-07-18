require 'test_helper'

class AccountOperationTest < ActiveSupport::TestCase
  test "bitcoin funding should refresh user addy" do
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo")

    o = Factory(:operation)

    o.account_operations << Factory.build(:account_operation,
      :currency => "BTC",
      :amount => -BigDecimal("10.0")
    )

    transfer = AccountOperation.new do |t|
      t.amount = BigDecimal("10.0")
      t.currency = "BTC"
      t.account = Factory(:user)
      t.bt_tx_id = "bar"
    end

    transfer.account.expects(:generate_new_address).at_least_once

    o.account_operations << transfer

    assert o.save
  end

  test "transaction sync should handle small txes without problem" do
    user = Factory(:user)

    tx = {
      "category" => "receive",
      "amount" => 0.00001,
      "confirmations" => 35414,
      "txid" => "0e0e9fec1195132b28662539528e936c981ebd3b0f140d9ad3c65717cf2f329a"
    }

    Bitcoin::Client.instance.
      stubs(:list_transactions).
      returns([tx], [tx])

    Account.stubs(:all).returns(User.where("id = ?", user.id))

    Bitcoin::Client.instance.
      stubs(:get_new_address).
      returns("foo")

    assert_difference 'user.balance(:btc)', 0.00001.to_d do
      assert_difference 'AccountOperation.count', 2 do
        AccountOperation.synchronize_transactions!
      end
    end

    # It should then not fail when updating the same transaction
    assert_no_difference 'user.balance(:btc)' do
      assert_no_difference 'AccountOperation.count' do
        AccountOperation.synchronize_transactions!
      end
    end
  end

  test "transfer should update user balance immediately" do
    user = Factory(:user)

    o = Factory(:operation)

    o.account_operations << AccountOperation.new do |t|
      t.amount = 10.0
      t.currency = "LREUR"
      t.account = user
    end

    o.account_operations << AccountOperation.new do |t|
      t.amount = -10.0
      t.currency = "LREUR"
      t.account = Factory(:account)
    end

    o.save!

    assert_equal BigDecimal("10.0"), user.balance(:lreur)
  end
end

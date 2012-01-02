require 'test_helper'

class EmailTransferTest < ActiveSupport::TestCase
  test "An user shouldn't be able to send more money than he has" do
    user = Factory(:user)
    user2 = Factory(:user,
            :email => "test@test.fr"
            )
    add_money(user, 100.0, :btc)

    transfer = EmailTransfer.new
    transfer.dest_email = "test@test.fr"
    transfer.currency = "BTC"
    transfer.amount = BigDecimal("110.0")

    assert_raise ActiveRecord::RecordInvalid do
      transfer.build
    end
    assert_equal user.balance("BTC"), BigDecimal("100.0")
  end

  test "EmailTransfer needs to be accepted by receiver" do
    user = Factory(:user)
    user2 = Factory(:user,
            :email => "test@test.fr"
            )

    add_money(user, 100.0, :btc)
    transfer = EmailTransfer.new
    transfer.dest_email = "test@test.fr"
    transfer.currency = "BTC"
    transfer.amount = BigDecimal("100.0")
    transfer.account_id = user.id

    transfer.build
    assert_equal user.balance(:btc), 0
    
  end
end

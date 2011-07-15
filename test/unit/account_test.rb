require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "should automatically create a storage account for each currency" do
    assert_difference 'Account.count' do
      Account.storage_account_for(:dummy)
    end
    
    # It shouldn't try to create the same account twice though
    assert_no_difference 'Account.count' do
      Account.storage_account_for(:dummy)
    end
  end
end

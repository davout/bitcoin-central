require 'test_helper'

class OperationTest < ActiveSupport::TestCase
  test "should not be valid if debit and credit are not equal for each currency" do
    o = Factory(:operation)
    
    o.account_operations << Factory.build(:account_operation, :currency => "EUR", :amount => 10.0.to_d)
    o.account_operations << Factory.build(:account_operation, :currency => "LREUR", :amount => 10.0.to_d)
    
    assert !o.valid?
    
    o.account_operations << Factory.build(:account_operation, :currency => "EUR", :amount => -10.0.to_d)
    
    assert !o.valid?
    
    o.account_operations << Factory.build(:account_operation, :currency => "LREUR", :amount => -10.0.to_d)
    
    assert o.valid?
  end
end

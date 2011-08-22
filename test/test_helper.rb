ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
  
  def login_with(user)
    sign_in(:user, user)
    user
  end

  def add_money(user, amount, currency)
    o = Factory(:operation)

    o.account_operations << Factory.build(:account_operation,
      :amount => amount,
      :account => user,
      :currency => currency.to_s.upcase
    )

    o.account_operations << Factory.build(:account_operation,
      :amount => -amount,
      :currency => currency.to_s.upcase
    )    
  end

  def assert_destroyed(instance, message = nil)
    assert instance.class.find(:all, :conditions => ["id = ?", instance.id]).blank?,
      message || "#{instance.class} with ID #{instance.id} should have been destroyed"
  end

  def assert_not_destroyed(instance, message = nil)
    assert instance.class.find(:first, :conditions => ["id = ?", instance.id]),
      message || "#{instance.class} with ID #{instance.id} shouldn't have been destroyed"
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

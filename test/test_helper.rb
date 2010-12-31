ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def login_with(user)
    session[:current_user_id] = users(user).id
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

require 'test_helper'

class MonkeyPatchesTest < ActiveSupport::TestCase
  test "should have SERIALIZABLE isolation level in transactions" do
    r = nil

    ActiveRecord::Base.transaction do
      r = ActiveRecord::Base.
        connection.
        execute("SELECT @@GLOBAL.tx_isolation, @@tx_isolation").
        to_a.
        flatten
    end

    assert_equal "SERIALIZABLE", r[1], "MySQL Transactions should run in SERIALIZABLE isolation level"
  end

  # IMO this should be fixed at Rails level
  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/json/encoding.rb
  # Oh yeah, also #as_json is buggy...
  # http://ternarylabs.com/2010/09/07/migrating-to-rails-3-0-gotchas-as_json-bug/
  test "BigDecimal should be serialized correctly in JSON" do
    d = BigDecimal("10")
    assert_equal "10.0", d.to_json
  end
  
  # Apparently it's not enough to override BigDecimal#to_json to get correct
  # hash serialization...
  test "hash serialization should honor raw BigDecimal serialization override" do
    data = { :amount => BigDecimal("10") }
    assert_equal "{\"amount\":10.0}", data.to_json
  end
end
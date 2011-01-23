require 'test_helper'

class MonkeyPatchesTest < ActiveSupport::TestCase

  test "should have SERIALIZABLE isolation level in transactions" do
    r = nil

    ActiveRecord::Base.transaction do
      r = ActiveRecord::Base.
        connection.
        execute("SELECT @@GLOBAL.tx_isolation, @@tx_isolation").
        fetch_row
    end

    assert_equal "SERIALIZABLE", r[1], "MySQL Transactions should run in SERIALIZABLE isolation level"
  end
end
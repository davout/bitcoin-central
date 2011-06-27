require 'test_helper'

class RailsTest < ActiveSupport::TestCase
  # This should be fixed in Rails itself
  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/big_decimal/conversions.rb
  test "BigDecimal#to_d should return self" do
    d = BigDecimal("10")
    assert_equal d.to_d, d, "BigDecimal#to_d did not return self"
  end
end
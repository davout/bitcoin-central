require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should correctly report user balance" do
    assert_equal 0.0, users(:trader1).balance(:btc)
    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)
    assert_equal 0.0, users(:trader2).balance(:lrusd)
  end
end

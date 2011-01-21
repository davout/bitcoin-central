require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should correctly report user balance" do
    assert_equal 0.0, users(:trader1).balance(:btc)
    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)
    assert_equal 0.0, users(:trader2).balance(:lrusd)
  end

  test "should correctly check API tokens" do
    u = users(:merchant)

    assert u.check_token("f561e3531aaf98ba9ae1551466d286a9b2dc256b052f8e7025aac9401083298a", 1295611205),
      "token should have been checked as valid"

    assert !u.check_token("f561e35failfailfailfailfailfail9b2dc256b052f8e7025aac9401083298a", 1295611205),
      "token should have been checked as invalid"
  end

  test "it shouldn't be too easy to cheat the authentication token" do
    # In case someone didn't define a secret word we don't want other people
    # to authenticate by just hashing a timestamp along with an empty string Oo'
    u = users(:trader1)
    timestamp = Time.now.to_i
    assert !u.check_token(Digest::SHA2.hexdigest(timestamp.to_s), timestamp),
      "we shouldn't be able to validate the authentication token with an empty secret word!"
  end
end

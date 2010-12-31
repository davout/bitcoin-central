require 'test_helper'

class BitcoinAddressValidatorTest < ActiveSupport::TestCase
  def setup
    @valid_addresses = [
      "1JTXnejf2fRoufKHkU9bMZcVuYhcGuUK6E",
      "1Dp2un5hz5BvMVvBWR8BCBREreC7EXiXdh",
      "15fQw8xvoQq8bFYU3QSR5RGfcFA5TKkLTD",
      "15xyuHyhVtS1kSekfckpejtLN1ytHZuvT4",
      "1PtzQKCsdNwU53ZVxr2kVXttf5G5B7LGg",
      "1CW5gA9wSvXSWpcMxbvzvMjTPg21eShz7L",
      "13FCDwKoMZeERELWiZQTtv5UQ9gMDwK915"
    ]

    @invalid_addresses = [
      "1JTXnejf2fRoufKHkU9bMZcVuYhcGuUK6E  ",
      "foo",
      "bar"
    ]
  end

  test "should accept some sample addresses as valid" do
    @valid_addresses.each do |address|
      assert valid?(address), "Address [#{address}] incorrectly failed validation"
    end
  end

  test "should reject junk as invalid" do
    @invalid_addresses.each do |address|
      assert !valid?(address), "Address [#{address}] incorrectly passed validation"
    end
  end

  def valid?(address)
    Bitcoin::Util.valid_bitcoin_address? address
  end
end

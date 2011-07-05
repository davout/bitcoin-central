require 'test_helper'

class BitcoinAddressValidatorTest < ActiveSupport::TestCase
  test "bitcoin address validator should delegate to Bitcoin::Client.instance" do
    class TestModel
      include ActiveModel::Validations
      attr_accessor :address
      validates :address, :bitcoin_address => true
    end

    Bitcoin::Client.instance.expects(:validate_address).with("foo").once.returns({ 'isvalid' => true })
    test_instance = TestModel.new
    test_instance.address = "foo"
    test_instance.valid?
  end
end

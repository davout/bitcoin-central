require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo", "bar")
    @invoice = Factory(:invoice)
  end

  test "should start in pending state" do
    assert_equal "pending", @invoice.state
  end

  test "should end in paid state" do
    @invoice.pay!
    assert_equal "paid", @invoice.state
  end

  test "should credit user when invoice is paid" do
    assert_difference 'AccountOperation.count', 2 do
      assert_difference '@invoice.user.reload.balance(:btc)', 100 do
        assert_difference "ActionMailer::Base.deliveries.size" do
          @invoice.pay!
        end
      end
    end
  end

  test "payment should be timestamped" do
    assert_nil @invoice.paid_at
    @invoice.payment_seen!
    assert @invoice.paid_at
  end
  
  test "should automatically generate a payment address" do
    invoice = Invoice.new do |i|
      i.amount = BigDecimal("100.0")
      i.user = Factory(:user)
      i.callback_url = "http://domain.tld/some_url"
    end
    
    assert_nil invoice.payment_address
    
    assert invoice.save
    assert invoice.payment_address
  end

  test "should automatically generate an authentication token" do
    invoice = Invoice.new do |i|
      i.amount = BigDecimal("100.0")
      i.user = Factory(:user)
      i.callback_url = "http://domain.tld/some_url"
    end
    
    assert_nil invoice.authentication_token

    assert invoice.save
    assert invoice.authentication_token
  end

  test "payment should get correctly timestamped even when ditching processing state" do
    invoice = Factory.build(:invoice)

    assert_nil invoice.paid_at
    assert invoice.save
    assert invoice.pay!
    assert invoice.paid_at
  end
  
  test "json representation should include the public URL" do
    assert !JSON.parse(Factory.build(:invoice).to_json)["invoice"]["public_url"].blank?
  end
end

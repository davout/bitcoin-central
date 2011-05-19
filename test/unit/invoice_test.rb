require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  def setup
    @invoice = Invoice.create(
      :user => users(:trader1),
      :amount => 100,
      :payment_address => '1FXWhKPChEcUnSEoFQ3DGzxKe44MDbatz',
      :callback_url => "http://domain.tld"
    )
  end

  test "should start in pending state" do
    assert_equal "pending", @invoice.state
  end

  test "should end in paid state" do
    @invoice.pay!
    assert_equal "paid", @invoice.state
  end

  test "should credit user when invoice is paid" do
    assert_difference 'Transfer.count' do
      assert_difference 'users(:trader1).balance(:btc)', 100 do
        assert_difference "ActionMailer::Base.deliveries.size" do
          @invoice.pay!
        end
      end
    end
  end

  test "payment should be timestamped" do
    assert_nil @invoice.paid_at
    @invoice.pay!
    assert @invoice.paid_at
  end
  
  test "should automatically generate a payment address" do
    invoice = Invoice.new({
        :user => users(:trader1),
        :amount => 100,
        :callback_url => "http://domain.tld"
      })
    
    assert_nil invoice.payment_address
    
    assert invoice.save
    assert invoice.payment_address
  end
end

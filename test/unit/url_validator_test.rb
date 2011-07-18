require 'test_helper'

class UrlValidatorTest < ActiveSupport::TestCase
  test "should consider an invoice invalid with an invalid url" do
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo")

    invoice = Invoice.new({
        :user => Factory(:user),
        :amount => 100,
        :payment_address => '1FXWhKPChEcUnSEoFQ3DGzxKe44MDbatz'
      })

    assert !invoice.valid?

    invoice.callback_url = "http://sub.domain.tld:8080/callback"
    
    assert invoice.valid?
  end
end

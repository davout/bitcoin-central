require 'test_helper'

class UrlValidatorTest < ActiveSupport::TestCase
  test "should consider an invoice invalid with an invalid url" do
    @invoice = Invoice.new({
        :user => User.first,
        :amount => 100,
        :payment_address => '1FXWhKPChEcUnSEoFQ3DGzxKe44MDbatz'
      })

    assert !@invoice.valid?

    @invoice.callback_url = "http://sub.domain.tld:8080/callback"

    assert @invoice.valid?
  end
end

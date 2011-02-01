require 'test_helper'

class ThirdPartyCallbacksControllerTest < ActionController::TestCase
  test "should create a pecunix deposit if nicely asked" do
    params = {
      "PAYEE_ACCOUNT" => "support@bitcoin-central.net",
      "PAYMENT_AMOUNT" => "1000.00",
      "PAYMENT_UNITS" => "GAU",
      "PAYMENT_REC_ID" => "000014568",
      "PAYER_ACCOUNT" => "customer@gold-cart.com",
      "PAYMENT_HASH" => "EC764D0A216D875269B24003C48297037583BA1A",
      "PAYMENT_GRAMS" => "1000.0000",
      "PAYMENT_ID" => users(:trader1).id.to_s,
      "PAYMENT_FEE" => "0.0002",
      "TXN_DATETIME" => "2002-04-10 10:14:54",
      "SUGGESTED_MEMO" => "Payment Bitcoin Central",
    }

    assert !Transfer.find_by_px_tx_id("000014568")
    assert users(:trader1).balance(:pgau).zero?

    assert_difference "Transfer.count" do
      post :px_status, params
      assert_response :success
    end

    # Posting the same data a second time should not result in any transfer
    # being created
    assert_no_difference "Transfer.count" do
      post :px_status, params
      assert_response :success
    end

    assert_equal 1000.0, users(:trader1).balance(:pgau)
    assert Transfer.find_by_px_tx_id("000014568")
    assert Transfer.find_by_px_payer("customer@gold-cart.com")
  end
end

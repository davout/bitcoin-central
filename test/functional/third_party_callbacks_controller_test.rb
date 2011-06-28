require 'test_helper'

class ThirdPartyCallbacksControllerTest < ActionController::TestCase
  test "should create a pecunix deposit if nicely asked" do
    params = {
      "PAYEE_ACCOUNT" => "support@bitcoin-central.net",
      "PAYMENT_AMOUNT" => "1.0000",
      "PAYMENT_UNITS" => "GAU",
      "PAYMENT_REC_ID" => "123456",
      "PAYER_ACCOUNT" => "user@domain.com",
      "PAYMENT_HASH" => "486A094C7DC2307A173BEB9158437E6134068022",
      "PAYMENT_GRAMS" => "1.0000",
      "PAYMENT_ID" => users(:trader1).id.to_s,
      "PAYMENT_FEE" => "0.0000",
      "TXN_DATETIME" => "2011-02-01 18:18:44",
      "SUGGESTED_MEMO" => "Payment Bitcoin Central",
    }

    assert !Transfer.find_by_px_tx_id("123456")
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

    assert_equal 1.0, users(:trader1).balance(:pgau)
    assert Transfer.find_by_px_tx_id("123456")
    assert Transfer.find_by_px_payer("user@domain.com")
  end
  
  # LR transfer creation test is in an integration test, for some reason
  # post :lr_create_from_sci picks the wrong action up :/
end

require 'test_helper'

class ThirdPartyCallbacksControllerTest < ActionController::TestCase
  test "should create a pecunix deposit if nicely asked" do
    user = Factory(:user, :id => 293383075)
    
    params = {
      "PAYEE_ACCOUNT" => "support@bitcoin-central.net",
      "PAYMENT_AMOUNT" => "1.0000",
      "PAYMENT_UNITS" => "GAU",
      "PAYMENT_REC_ID" => "123456",
      "PAYER_ACCOUNT" => "user@domain.com",
      "PAYMENT_HASH" => "486A094C7DC2307A173BEB9158437E6134068022",
      "PAYMENT_GRAMS" => "1.0000",
      "PAYMENT_ID" => "293383075",
      "PAYMENT_FEE" => "0.0000",
      "TXN_DATETIME" => "2011-02-01 18:18:44",
      "SUGGESTED_MEMO" => "Payment Bitcoin Central",
    }

    assert !AccountOperation.find_by_px_tx_id("123456")
    assert user.balance(:pgau).zero?

    assert_difference "AccountOperation.count", 2 do
      post :px_status, params
      assert_response :success
    end

    # Posting the same data a second time should not result in any transfer
    # being created
    assert_no_difference "AccountOperation.count" do
      post :px_status, params
      assert_response :success
    end

    assert_equal BigDecimal("1.0"), user.balance(:pgau)
    assert AccountOperation.find_by_px_tx_id("123456")
    assert AccountOperation.find_by_px_payer("user@domain.com")
  end
  
  # LR transfer creation test is in an integration test, for some reason
  # post :lr_create_from_sci picks the wrong action up :/
end

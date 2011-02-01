require 'test_helper'

class ApiAuthenticationTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "authentication should fail with wrong token" do
    get account_path, :authentication => {
      :account => "BC-M000000",
      :timestamp => Time.now.to_i,
      :token => "wrong token"
    }

    assert_response :forbidden
  end
  
  test "authentication should work with correct token" do
    timestamp = Time.now.to_i.to_s
    token = Digest::SHA2.hexdigest("#{users(:merchant).secret_token}#{timestamp}")

    get account_path, :authentication => {
      :account => "BC-M000000",
      :timestamp => timestamp,
      :token => token
    }

    assert_response :success
  end
  
  test "authentication should fail with wrong credentials" do
    get account_path, :authentication => {
      :account => "BC-M000000",
      :password => "wrong pass"
    }
    assert_response :forbidden
  end
  
  test "authentication should work with credentials" do
    get account_path, :authentication => {
      :account => "BC-M000000",
      :password => "pass"
    }
    assert_response :success
  end
  
  test "authentication should fail with and old token" do
    timestamp = (Time.now.to_i - (60 * 60 * 24)).to_s
    token = Digest::SHA2.hexdigest("#{users(:merchant).secret_token}#{timestamp}")

    get account_path, :authentication => {
      :account => "BC-M000000",
      :timestamp => timestamp,
      :token => token
    }

    assert_response :forbidden
  end
  
  test "get account history in XML using API" do
    timestamp = Time.now.to_i.to_s
    token = Digest::SHA2.hexdigest("#{users(:merchant).secret_token}#{timestamp}")

    get account_transfers_path, :format => :xml, :authentication => {
      :account => "BC-M000000",
      :timestamp => timestamp,
      :token => token
    }

    assert_response :success
    assert_template "transfers/index"
    assert_equal MIME::Types['application/xml'].to_s, @response.content_type.to_s
  end
  
  test "post a trade order using XML API" do
    xml_string = "<api><authentication account=\"BC-T000000\" password=\"pass\" />"
    xml_string << "<trade_order category=\"buy\" amount=\"1\" ppc=\"1\" currency=\"LRUSD\" />"
    xml_string << "</api>"

    assert_difference "Transfer.count", 4 do
      post account_trade_orders_path, xml_string,{ "CONTENT_TYPE" => "application/xml" }
      assert_response :redirect
      assert_redirected_to account_trade_orders_path
    end
  end
  
  test "post a trade order using JSON API" do
    json_string = "{ 'authentication' : { 'account' : 'BC-T000000', 'password' : 'pass' }, "
    json_string << "'trade_order' : { 'category' : 'buy', 'amount' : 1, 'ppc' : 1, 'currency' : 'LRUSD' } }"

    assert_difference "Transfer.count", 4 do
      post account_trade_orders_path, json_string,{ "CONTENT_TYPE" => "application/json" }
      assert_response :redirect
      assert_redirected_to account_trade_orders_path
    end
  end
end

require 'test_helper'

class HttpBasicAuthTest < ActionDispatch::IntegrationTest
  test "basic auth should be available and working" do
    user = Factory(:user)
    headers = {}
    
    get '/account', {}, headers
    assert_response :redirect 
    
    # Wrong HTTP Basic authentication header
    authorization = ActiveSupport::Base64.encode64("some_wrong_user:password")
    headers = { 'HTTP_AUTHORIZATION' => "Basic #{authorization}" }
    
    get '/account', {}, headers
    assert_response :redirect
    
    # Correct HTTP Basic authentication header
    authorization = ActiveSupport::Base64.encode64("#{user.email}:password")
    headers = { 'HTTP_AUTHORIZATION' => "Basic #{authorization}" }
    
    get '/account', {}, headers
    assert_response :success
  end
  
  test "http basic auth should also work w account number" do
    user = Factory(:user)
    
    # Correct HTTP Basic authentication header
    authorization = ActiveSupport::Base64.encode64("#{user.name}:password")
    headers = { 'HTTP_AUTHORIZATION' => "Basic #{authorization}" }
    
    get '/account', {}, headers
    assert_response :success
  end
  
  test "basic auth should not work with a second auth factor enabled" do
    user = Factory(:user, :require_yk_otp => true)
    
    # Correct HTTP Basic authentication header
    authorization = ActiveSupport::Base64.encode64("#{user.name}:password")
    headers = { 'HTTP_AUTHORIZATION' => "Basic #{authorization}" }
    
    get '/account', {}, headers
    assert_response :redirect  
  end
end

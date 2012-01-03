require 'test_helper'

class IphoneTest < ActionDispatch::IntegrationTest
  def setup
    @headers = { "HTTP_USER_AGENT" => "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3" }
  end
 
# This test fails since we're now always including the apple touch metadata
# in order to get the iPad working properly
# 
#  test "should get a specific layout" do
#    get new_user_session_path
#    assert_response :success
#    assert_nil @response.body =~ /apple-touch-startup-image/
#    
#    get new_user_session_path, {}, @headers
#    assert_response :success
#    assert @response.body =~ /apple-touch-startup-image/
#  end

  test "should be sent straight to sign-in" do
    get "/"
    assert_response :success
    
    get "/", {}, @headers
    assert_response :redirect
    
    assert_redirected_to new_user_session_path
  end
end

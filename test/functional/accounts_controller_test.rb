require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  test "should render deposits page" do
    login_with(Factory(:user))
    get :deposit
    assert_response :success
  end
  
  test "should get pecunix deposit form" do
    login_with(Factory(:user))
    get :pecunix_deposit_form, :format => :js
    assert_response :success
  end
  
  test "should get balances in json" do
    login_with(Factory(:user))
    get :show, :format => :json
    assert_response :success
  end
end

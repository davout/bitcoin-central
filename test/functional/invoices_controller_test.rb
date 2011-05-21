require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  def setup
    login_with :trader1
  end

  test "should get invoice list" do
    get :index
    assert_response :success
  end

  test "should get invoice creation form" do
    get :new
    assert_response :success
  end

  test "should create invoice" do    
    assert_difference 'Invoice.count' do
      post :create, :invoice => {
        :amount => 100,
        :callback_url => "http://domain.tld"
      }

      assert_response :redirect
      assert_redirected_to Invoice.last
    end
  end
  
  test "should discard address if posted through params" do
    address = '1FXWhKPChEcUnSEoFQ3DGzxKe44MDbatz'
      
    assert_difference 'Invoice.count' do
      post :create, :invoice => {
        :amount => 100,
        :payment_address => address,
        :callback_url => "http://domain.tld"
      }
      
      assert !Invoice.last.payment_address.blank?
      assert_not_equal Invoice.last.payment_address, address
    end
  end

  test "should deny unauthenticated invoice display" do
    sign_out :user
    get :show, :id => invoices(:invoice1).id

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should redirect to root path with wrong authentication token" do
    sign_out :user
    get :show, :id => invoices(:invoice1).id,
      :authentication_token => "boom_boom"

    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should display invoice with correct authentication token" do
    sign_out :user
    get :show, :id => invoices(:invoice1).id,
      :authentication_token => "knock_knock"

    assert_response :success
    assert_equal invoices(:invoice1), assigns(:invoice)
  end
end

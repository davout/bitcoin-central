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

  test "should not show other users invoices" do
    get :show, :id => invoices(:invoice1) # owned by users(:merchant)
    assert_response :redirect
    assert_redirected_to invoices_path
  end

  test "should show owned invoices" do
    sign_out :user
    login_with :merchant
    get :show, :id => invoices(:invoice1)
    assert_response :success
  end

  test "should create invoice" do    
    assert_difference 'Invoice.count' do
      post :create, :invoice => {
        :amount => 100,
        :callback_url => "http://domain.tld"
      }

      assert_response :redirect
      assert_redirected_to assigns(:invoice)
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
      
      assert !assigns(:invoice).payment_address.blank?
      assert_not_equal assigns(:invoice).payment_address, address
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
  
  test "should destroy invoice" do
    sign_out :user
    login_with :merchant
    
    assert_difference "Invoice.count", -1 do
      delete :destroy, :id => invoices(:invoice1).id
      assert flash[:notice]
    end
  end
end

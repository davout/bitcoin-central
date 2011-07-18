require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  def setup
    @user = login_with(Factory(:user))
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
    get :show, :id => Factory(:invoice, :user => Factory(:user)) # owned by users(:merchant)
    assert_response :redirect
    assert_redirected_to invoices_path
  end

  test "should show owned invoices" do
    sign_out :user
    merchant = login_with(Factory(:user, :merchant => true))
    invoice = Factory(:invoice, :user => merchant)

    get :show, :id => invoice.id
    assert_response :success
  end

  test "should create invoice" do
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo")
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)

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
    Bitcoin::Client.instance.stubs(:get_new_address).returns("foo")
    Bitcoin::Util.stubs(:valid_bitcoin_address?).returns(true)

    address = '1FXWhKPChEcUnSEoFQ3DGzxKe44MDbatz'
      
    assert_difference 'Invoice.count' do
      post :create, :invoice => {
        :amount => 100,
        :payment_address => address,
        :callback_url => "http://domain.tld"
      }
      
      assert !assigns(:invoice).payment_address.blank?
      assert_not_equal assigns(:invoice).payment_address, address
      assert_equal assigns(:invoice).payment_address, "foo"
    end
  end

  test "should deny unauthenticated invoice display" do
    sign_out :user
    get :show, :id => Factory(:invoice).id

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should redirect to root path with wrong authentication token" do
    sign_out :user
    invoice = Factory(:invoice, :authentication_token => "knock knock")

    get :show, :id => invoice.id,
      :authentication_token => "boom boom"

    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should display invoice with correct authentication token" do
    sign_out :user
    invoice = Factory(:invoice, :authentication_token => "knock_knock")
  
    get :show, :id => invoice.id,
      :authentication_token => "knock_knock"

    assert_response :success
    assert_equal invoice, assigns(:invoice)
  end
  
  test "should destroy invoice" do
    sign_out :user
    merchant = login_with(Factory(:user, :merchant => true))
    invoice = Factory(:invoice, :user => merchant)
    
    assert_difference "Invoice.count", -1 do
      delete :destroy, :id => invoice.id
      assert flash[:notice]
    end
  end
end

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
      assert_redirected_to invoices_path
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
end

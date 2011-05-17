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
        :payment_address => '1FXWhKPChEcUnSEoFQ3DGzxKe44MDbatz',
        :callback_url => "http://domain.tld"
      }

      assert_response :redirect
      assert_redirected_to invoices_path
    end
  end
end

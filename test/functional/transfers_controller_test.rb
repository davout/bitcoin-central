require 'test_helper'

class TransfersControllerTest < ActionController::TestCase
  def setup
    @user = login_with(Factory(:user))
    @other_user = Factory(:user)
    add_money(@user, 25.0, :lrusd)    
  end

  test "should transfer money to another account" do
    assert_equal 25.0, @user.balance(:lrusd)

    assert_difference "Transfer.count", 2 do
      post :create, :payee => @other_user.name, :transfer => {
        :currency => "LRUSD",
        :amount => 5.0
      }
      
      assert_response :redirect
      assert_redirected_to account_transfers_path
    end

    assert_equal 20.0, @user.balance(:lrusd)
    assert_equal 5.0, @other_user.balance(:lrusd)
  end
  
  test "should show account history page" do
    get :index
    assert_response :success
  end
  
  test "should show transfer details" do
    get :show, :id => @user.account_operations.first.id
    assert_response :success
  end
end

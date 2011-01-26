require 'test_helper'

class TransfersControllerTest < ActionController::TestCase
  def setup
    login_with :trader1
  end

  test "should transfer money to another account" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)

    assert_difference "Transfer.count", 2 do
      post :create, :payee => "BC-T000001", :transfer => {
        :currency => "LRUSD",
        :amount => 5
      }

      assert_response :redirect
      assert_redirected_to account_transfers_path
    end

    assert_equal 20.0, users(:trader1).balance(:lrusd)
    assert_equal 5.0, users(:trader2).balance(:lrusd)
  end
end

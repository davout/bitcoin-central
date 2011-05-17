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
end

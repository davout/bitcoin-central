require 'test_helper'

class InformationsControllerTest < ActionController::TestCase
  test "should get frontpage" do
    get :welcome
    assert_response :success
  end
end

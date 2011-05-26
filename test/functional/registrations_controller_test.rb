require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "should sign-in user and redirect to account after sign-up" do
    assert_difference "ActionMailer::Base.deliveries.size" do
      assert_difference "User.count" do
        post :create, :user => {
          :email => "user@example.com",
          :password => "123456",
          :password_confirmation => "123456"
        }
      end
    
      assert_response :redirect
      assert_redirected_to root_path
    end
  end
end

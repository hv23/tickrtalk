require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase
  def setup
    @request.env["HTTP_REFERER"] = "http://localhost:3000/"
  end
  
  test "should login user" do
    post :create, :user => User.plan 
    assert_response :success
  end

  test "should not login user" do
    post :create, :user => User.plan(:fail)
    assert_response :success
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should logout user" do
    @user = User.first
    @request.session[:user_id] = @user.id    
    
    post :destroy  
    assert_redirected_to root_url
  end
end

require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get view" do
    get :index
    assert_response :success
  end
  
  test "should get ticker" do
    get :ticker
    assert_response :success
  end 
end

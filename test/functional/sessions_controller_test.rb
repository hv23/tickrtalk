require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  def setup
    @request.env["HTTP_REFERER"] = "http://localhost:3000/"
  end
  
  test "should get twitter_signup" do      
    get :twitter_signup
    assert_response :success
  end
  
  test "should get facebook_signup" do      
    get :facebook_signup
    assert_response :success
  end
end

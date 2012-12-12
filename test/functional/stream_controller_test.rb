require 'test_helper'

class StreamControllerTest < ActionController::TestCase
  # Stream is not used right now

  # test "should get stream" do    
  #   get :index
  #   assert_response :success
  # end
  # 
  # test "should get liveview" do    
  #   get :liveview
  #   assert_response :success
  # end
  # 
  # test "should get following" do
  #   UserSession.create(users(:johnny))
  #   
  #   get :following
  #   assert_response :success
  #   assert_template("stream/index")
  #   assert_equal(1, assigns(:updates).size)
  # end
  # 
  # test "should not get following" do    
  #   get :following
  #   assert_redirected_to "/stream"
  #   assert_equal("You have to be logged into view your following stream.", flash[:notice])
  #   assert_template("")
  # end
end

require 'test_helper'

class PrivateUpdatesControllerTest < ActionController::TestCase
  def setup
    @private_gameroom = PrivateGameroom.make
    @private_update = PrivateUpdate.make
    @user = User.first
    @request.session[:user_id] = @user.id
  end

  test "should get update" do    
    get :show, :id => @private_update.id, :gameroom_key => @private_gameroom.gameroom_key
    assert_response :success
  end
  
  test "should add line" do    
    post :add_line, :update => PrivateUpdate.plan, :gameroom_key  => @private_gameroom.gameroom_key
    assert_redirected_to private_gameroom_url(@private_gameroom.id, :gameroom_key  => @private_gameroom.gameroom_key)
  end
  
  test "should reset form" do  
    assert_response :success
  end
end

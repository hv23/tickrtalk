require 'test_helper'

class UpdateControllerTest < ActionController::TestCase
  def setup
    @game = Game.first
    @update = Update.make
    @user = User.first
    @request.session[:user_id] = @user.id
    @request.session[:send_to_facebook] = "false"
  end

  test "should get view" do    
    get :view, :id => @update.id
    assert_response :success
  end
  
  test "should add line" do    
    post :add_line, :id => @game.id, :update => Update.plan
    assert_redirected_to "/gameroom/" + @game.id.to_s
  end
  
  test "should reset form" do  
    assert_response :success
  end 
end

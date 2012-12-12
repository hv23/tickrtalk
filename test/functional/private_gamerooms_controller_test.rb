require 'test_helper'

class PrivateGameroomsControllerTest < ActionController::TestCase

  def setup
    @game = Game.first
    @private_gameroom = PrivateGameroom.make
    @user = User.first
    @request.session[:user_id] = @user.id
  end
  
  test "should get new" do
    get :new, :game_id => @game.id
    assert_response :success
    assert_template("new")
  end
  
  test "should get edit" do
    get :edit, :gameroom_key => @private_gameroom.gameroom_key, :id => @game.id
    assert_response :success
    assert_template("edit")
  end
  
  test "should create new private gameroom" do
    post :create, :private_gameroom => PrivateGameroom.plan
    assert_redirected_to "gameroom/"+assigns(:gameroom).game_id.to_s
  end
  
  test "should update private gameroom" do
    post :update, :id => @private_gameroom.id
    assert_redirected_to "gameroom/"+assigns(:gameroom).game_id.to_s
  end
  
end

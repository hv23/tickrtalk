require 'test_helper'

class GameroomControllerTest < ActionController::TestCase
  
  def setup
    @game = Game.first
    @private_gameroom = PrivateGameroom.make
    @user = User.first
    @request.session[:user_id] = @user.id
  end  
    
  test "should get gameroom" do
    get :index, :id => @game.id
    assert_response :success
  end
  
  test "should send to twitter" do
    @request.session[:send_to_twitter] = 'false'
    
    get :send_to_twitter
    assert_equal(nil, @request.session[:send_to_twitter])
  end
  
  test "should not send to twitter" do
    @request.session[:send_to_twitter] = nil
    
    get :send_to_twitter
    assert_equal('false', @request.session[:send_to_twitter])
  end
  
  test "should send to facebook" do
    @request.session[:send_to_facebook] = 'false'
    
    get :send_to_facebook
    assert_equal(nil, @request.session[:send_to_facebook])
  end
  
  test "should not send to facebook" do
    @request.session[:send_to_facebook] = nil
    
    get :send_to_facebook
    assert_equal('false', @request.session[:send_to_facebook])
  end
  
  test "should get replies" do
    get :replies, :id => @game.id
    assert_redirected_to '/gameroom/' + @game.id.to_s
  end
  
  test "should get all updates" do    
    get :all_updates, :id => @game.id
    assert_redirected_to '/gameroom/' + @game.id.to_s
  end
  
  test "should get following" do
    get :following, :id => @game.id
    assert_redirected_to '/gameroom/' + @game.id.to_s
  end
  
  test "should get tickrtalk only" do
    get :tickrtalk_only, :id => @game.id
    assert_redirected_to '/gameroom/' + @game.id.to_s
  end 
  
  test "should get twitter only" do
    get :twitter_only, :id => @game.id
    assert_redirected_to '/gameroom/' + @game.id.to_s
  end 
  
  test "should get private_gameroom" do
    get :private_gameroom, :id => @game.id, :gameroom_key => @private_gameroom.gameroom_key, :private_gameroom_id => @private_gameroom.id
    assert_response :success
  end
end

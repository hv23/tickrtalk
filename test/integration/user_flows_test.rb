require 'test_helper'
require 'fake_web'
require 'open-uri'

class UserFlowsTest < ActionController::IntegrationTest  
  def setup
    @game = Game.first
    post '/user_sessions/create', {:user => {:username => 'johnny', :password => 'testing1'}}, {:referer => "/"}
  end 

  test "should signup and browse site" do
    post "/signup", :user => {:username => "johnnytest", :password => "test", :password_confirmation => "test", :email => "johnnytest@test.com" }
    assert_equal '/signup', path 
        
    https!(false)  
    get "/games/"  
    assert_response :success  
    assert assigns(:games)
    
    https!(false)  
    get "/teams"  
    assert_response :success  
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s
    assert_response :success
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/replies"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/tickrtalk_only"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/twitter_only"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/following"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/send_to_twitter"  
    assert_response :redirect
  end 
  
  test "should login and browse site" do
    post "/login", {:username => "johnny", :password => "testing1"}, {:referer => "/"}
    assert_equal '/login', path
    
    https!(false)  
    get "/games/"  
    assert_response :success  
    assert assigns(:games)
    
    https!(false)  
    get "/teams"  
    assert_response :success  
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s  
    assert_response :success
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/replies"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/tickrtalk_only"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/twitter_only"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/following"  
    assert_response :redirect
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s + "/send_to_twitter"  
    assert_response :redirect
  end
  
  test "should login to twitter" do
    post "/session"
    assert_equal("/session", path)
    
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:post, 'http://twitter.com/oauth/request_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
    FakeWeb.register_uri(:post, 'http://twitter.com/oauth/access_token', :body => 'oauth_token=fake&oauth_token_secret=fake')
    FakeWeb.register_uri(:get, 'http://twitter.com/account/verify_credentials.json', :response => File.join(RAILS_ROOT, 'test', 'fixtures', 'verify_credentials.json'))  
        
    assert_redirected_to "http://api.twitter.com/oauth/authenticate?oauth_token=#{session['rtoken']}"
    
    # Twitter finalize shouldn't work
    post "/sessions/finalize", {:oauth_token=> session['rtoken'], :oauth_verifier => session['rsecret']}
    assert_equal("/sessions/finalize", path)
  end
  
  test "should login, follow user, unfollow user, add a team, remove a team, and browse" do
    user = User.all.last
    team = Team.make
        
    post "/login", {:username => "johnny", :password => "johnny"}, {:referer => "/"}
    assert_equal '/login', path
    
    get "/users/" + user.username
    assert_response :success
    assert_template "users/show"
    
    post "/users/togglefollow/" + user.id.to_s
    assert_response :redirect
    
    get "/teams/" + team.id.to_s
    assert_response :success
    assert_template "teams/view"
    
    https!(false)  
    get "/games/"  
    assert_response :success  
    assert assigns(:games)
    
    https!(false)  
    get "/teams"  
    assert_response :success
  end
  
  test "should login, get private gameroom, and add update" do
    private_gameroom = PrivateGameroom.make
    private_update = PrivateUpdate.make
    
    post "/login", {:username => "johnny", :password => "johnny"}, {:referer => "/"}
    assert_equal '/login', path
    
    https!(false)  
    get "/gameroom/" + @game.id.to_s
    assert_response :success
    
    get "/private_gamerooms/" + private_gameroom.id.to_s + "?gameroom_key=" + private_gameroom.gameroom_key.to_s
    assert_response :redirect
    
    # assert_difference('PrivateUpdate.count') do          
    #   post "/private_updates/add_line?gameroom_key=" + private_gameroom.gameroom_key.to_s, :update => Update.plan
    #   # assert_redirected_to "/private_gamerooms/" + private_gameroom.id.to_s + "?gameroom_key=" + private_gameroom.gameroom_key.to_s
    #   assert_response :redirect
    # end
    
    get "/private_updates/" + private_update.id.to_s + "?gameroom_key=" + private_update.private_gameroom.gameroom_key.to_s
    assert_response :success
  end
end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @team = Team.first
    @request.env["HTTP_REFERER"] = "http://localhost:3000/"
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_template("new")
  end

  test "should get show" do
    get :show, :id => User.first.username
    assert_response :success
    assert_template("show")
  end
  
  test "should register user" do
    post :create, :user => {:username => 'johnnytest', :password => 'johnnytest', :password_confirmation => 'johnnytest', :email => "johnnytest@test.com"}
    assert_equal("Welcome to TickrTalk, johnnytest!", flash[:notice])
    assert_redirected_to root_url
  end

  test "should not register user" do
    post :create, :user => {:username => 'johnnytest', :password => 'johnnytest', :password_confirmation => '', :email => "johnnytest@test.com"}
    assert_response :success
    assert_template("new")
  end
  
  test "should register twitter user" do
    post :create, :user => { :username => 'tester', :password => 'johnnytest', :password_confirmation => 'johnnytest', :email => "test@test.com"}, :session => { :twitter_name => "johnnytickr", :twitter_token => "token", :twitter_secret => "secret" }
    assert_equal("Welcome to TickrTalk, tester!", flash[:notice])
    assert_equal(nil, session[:twitter_name])
    assert_redirected_to root_url
  end
  
  test "should get edit" do
    @user = User.first
    @request.session[:user_id] = @user.id
    
    get :edit
    assert_response :success
    assert_template("edit")
  end
  
  test "should update user" do
    @user = User.first
    @request.session[:user_id] = @user.id
    
    post :update, :user => {:username => 'johnnytest', :password => 'johnnytest', :password_confirmation => 'johnnytest', :email => "johnny@test.com"}
    assert_equal("Successfully updated profile.", flash[:notice])
    assert_redirected_to account_url
  end
  
  test "should not update user" do
    @user = User.first
    @request.session[:user_id] = @user.id
    
    post :update, :user => {:username => '', :password => '', :password_confirmation => '', :email => "johnny@test.com"}
    assert_response :redirect
  end
  
  test "should togglefollow" do
    @login = User.all.last
    @request.session[:user_id] = @login.id
    @user = User.first
    
    post :togglefollow, :id => @user.id
    assert_response :redirect
    
    post :togglefollow, :id => @user.id
    assert_response :redirect
  end
  
  test "should become a fan and stop being a fan" do
    @user = User.first
    @request.session[:user_id] = @user.id
    
    post :fan, :id => @team.id
    assert_response :redirect
    
    post :fan, :id => @team.id
    assert_response :redirect
  end
  
  test "should get user gamerooms" do
    @user = User.first
    @request.session[:user_id] = @user.id

    get :gamerooms
    assert_response :success
    assert_template("gamerooms")    
  end
  
end

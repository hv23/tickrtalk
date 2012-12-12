require 'test_helper'

class MyteamsControllerTest < ActionController::TestCase
  def setup
    @team = Team.first
    @user = User.make
    @request.session[:user_id] = @user.id
  end

  test "should get games" do
    get :index
    assert_response :success
  end
  
  test "should get edit" do
    get :edit
    assert_response :success
  end
  
  test "should add team" do
    post :addteam, :id => @team.id
    assert_response :success
  end
  
  test "should remove team" do
    post :removeteam, :id => @team.id
    assert_response :redirect
  end
  
  test "should search for team" do
    post :autocomplete, :q => "Oklahoma"
    assert_response :success
  end
end

require 'test_helper'

class TeamsControllerTest < ActionController::TestCase

  test "should get games" do
    get :index
    assert_response :success
  end
  
  test "should get view" do
    get :view, :id => Team.first.id
    assert_response :success
  end
  
  test "should quick search" do
    get :quicksearch, :q => "Oklahoma"
    assert_response :success
  end
  
  test "should not quick search" do
    get :quicksearch, :q => ""
    assert_response :success
  end
  
  test "should get league" do
    get :league, :id => Team.first.league
    assert_response :success
  end

end

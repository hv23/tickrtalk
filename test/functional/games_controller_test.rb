require 'test_helper'

class GamesControllerTest < ActionController::TestCase

  test "should get games" do
    get :index
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

end

require 'test_helper'

class GameTest < ActiveSupport::TestCase
  
  should 'create a game' do
    game = Game.make(:world_cup)
    assert_equal "Spain", game.away_team
    assert_equal "Netherlands", game.home_team
  end
  
end

require 'test_helper'

class TeamTest < ActiveSupport::TestCase

  should 'create a team' do
    team = Team.make(:osu)
    assert_equal "Cowboys", team.mascot
    assert_equal "Oklahoma St Cowboys", team.team_name
  end
  
end

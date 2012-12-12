require 'test_helper'

class SportTest < ActiveSupport::TestCase

  should 'create a sport' do
    sport = Sport.make
    assert_match /\w/, sport.name
    assert_match /\w/, sport.short
  end
  
end

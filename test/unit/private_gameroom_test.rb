require 'test_helper'

class PrivateGameroomTest < ActiveSupport::TestCase

  should 'create a private gameroom' do
    private_gameroom = PrivateGameroom.make
    assert_match /\w/, private_gameroom.login
    assert_not_nil private_gameroom.gameroom_key
  end
  
  should 'not create a private gameroom' do
    private_gameroom = PrivateGameroom.new(PrivateGameroom.plan(:no_login))
    private_gameroom.valid?
    assert_equal "can't be empty", private_gameroom.errors[:login].first
  end
  
end

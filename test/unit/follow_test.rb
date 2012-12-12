require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  Follow.delete_all

  should 'follow a user' do
    follow = Follow.make
    assert_not_nil follow.followed_id
    assert_not_nil follow.follower_id
  end

end

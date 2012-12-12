require 'test_helper'

class PrivateUpdateTest < ActiveSupport::TestCase

  should 'create a private update' do
    private_update = PrivateUpdate.make
    assert_match /\w/, private_update.user.username
    assert_not_nil private_update.content
  end
  
end

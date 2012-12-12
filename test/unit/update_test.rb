require 'test_helper'

class UpdateTest < ActiveSupport::TestCase
  
  should 'create an update' do
    update = Update.make
    assert_match /\w/, update.user.username
    assert_not_nil update.content
  end
  
end

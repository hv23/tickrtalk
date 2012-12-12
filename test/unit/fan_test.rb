require 'test_helper'

class FanTest < ActiveSupport::TestCase
  Fan.delete_all
  
  should 'become a fan' do
    fan = Fan.make
    assert_not_nil fan.user_id
    assert_not_nil fan.team_id
  end
  
end

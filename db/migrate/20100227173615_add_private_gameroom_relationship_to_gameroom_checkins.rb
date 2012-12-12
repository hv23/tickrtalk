class AddPrivateGameroomRelationshipToGameroomCheckins < ActiveRecord::Migration
  def self.up
    add_column :gameroom_checkins, :private_gameroom_id, :integer
  end

  def self.down
    remove_column :gameroom_checkins, :private_gameroom_id
  end
end

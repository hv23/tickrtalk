class AddGameroomKeyFieldToPrivateGamerooms < ActiveRecord::Migration
  def self.up
    add_column :private_gamerooms, :gameroom_key, :string
  end

  def self.down
    remove_column :private_gamerooms, :single_access_token
  end
end

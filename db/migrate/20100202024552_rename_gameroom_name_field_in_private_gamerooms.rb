class RenameGameroomNameFieldInPrivateGamerooms < ActiveRecord::Migration
  def self.up
    rename_column :private_gamerooms, :gameroom_name, :login
  end

  def self.down
    rename_column :private_gamerooms, :login, :gameroom_name
  end
end

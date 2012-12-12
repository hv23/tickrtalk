class RenameGames < ActiveRecord::Migration
  def self.up
    rename_table :games, :games_old
  end

  def self.down
  end
end

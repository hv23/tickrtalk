class RenameTeams < ActiveRecord::Migration
  def self.up
    rename_table :teams, :teams_old
  end

  def self.down
    drop_table :teams
  end
end

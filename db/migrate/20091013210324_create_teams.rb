class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
			t.integer :sport_id
      t.string :team_name, :limit => 100,  :null => false
      t.string :team, :limit => 50,  :null => false
      t.string :mascot, :limit => 50,  :null => true
      t.string :league, :limit => 30,  :null => true
      t.string :resource, :limit => 100,  :null => true
      t.string :resource_path, :limit => 100,  :null => true
 
      t.timestamps
		end
  end

  def self.down
    drop_table :teams
  end
end

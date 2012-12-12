class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.string :loseteamname, :limit => 50,  :null => false
      t.string :season_type, :limit => 50,  :null => true
      t.string :winteamlink, :limit => 100,  :null => false
      t.string :season_year, :limit => 10,  :null => true
      t.integer :winscore,  :limit => 8,  :null => false
      t.string :winteamname, :limit => 50,  :null => false
      t.string :loseteamlink, :limit => 100,  :null => false
      t.boolean :is_college, :default => 0
      t.integer :losescore,  :limit => 8,  :null => false
      t.string :league, :limit => 50,  :null => false     
      t.string :sport, :limit => 30,  :null => false 
      t.string :eventlink, :limit => 100,  :null => false     
      t.timestamps
    end
  end

  def self.down
  end
end

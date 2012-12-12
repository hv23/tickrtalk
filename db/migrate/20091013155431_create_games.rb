class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.date :date,  :null => true
      t.time :time,  :null => true
      t.string :name, :limit => 50,  :null => true
			t.string :league, :limit => 10,  :null => true
      t.integer :home_score,  :limit => 8,  :null => true
      t.string :home_team,  :limit => 50,  :null => true
      t.string :home_winlose,  :limit => 1,  :null => true
      t.integer :away_score,  :limit => 8,  :null => true
      t.string :away_team,  :limit => 50,  :null => true
      t.string :away_winlose,  :limit => 1,  :null => true
      t.string :status, :limit => 30,  :null => true
      t.string :resource_text, :limit => 100,  :null => true
			t.game_datetime :datetime, :null => true
 
      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end

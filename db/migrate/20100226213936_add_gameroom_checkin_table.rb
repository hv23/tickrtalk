class AddGameroomCheckinTable < ActiveRecord::Migration
  def self.up
    create_table :gameroom_checkins do |t|
      t.integer :game_id
      t.integer :user_id
      t.string :gameroom_key, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :gameroom_checkins
  end
end

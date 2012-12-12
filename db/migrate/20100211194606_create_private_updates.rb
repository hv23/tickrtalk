class CreatePrivateUpdates < ActiveRecord::Migration
  def self.up
    create_table :private_updates do |t|
      t.integer :user_id, :null => false
      t.integer :private_gameroom_id, :null => false
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :private_updates
  end
end
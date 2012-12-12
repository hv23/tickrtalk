class CreatePrivateGamerooms < ActiveRecord::Migration
  def self.up
    create_table :private_gamerooms do |t|
      t.string :gameroom_name 
      t.integer :game_id
      t.integer :user_id  
      t.string :crypted_password  
      t.string :password_salt  
      t.string :persistence_token
      t.integer :users_login_count
      t.timestamps
    end
  end

  def self.down
    drop_table :private_gamerooms
  end
end

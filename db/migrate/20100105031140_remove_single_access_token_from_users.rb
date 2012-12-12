class RemoveSingleAccessTokenFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :single_access_token  
  end

  def self.down
    add_column :users, :single_access_token, :string, :null => false
  end
end

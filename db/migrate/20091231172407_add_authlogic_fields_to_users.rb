class AddAuthlogicFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_salt, :string, :null => false
    add_column :users, :persistence_token, :string, :null => false
    add_column :users, :single_access_token, :string, :null => false
    add_column :users, :perishable_token, :string, :null => false
    add_column :users, :login_count, :integer, :null => false, :default => 0
    add_column :users, :last_login_at, :datetime
    add_column :users, :last_login_ip, :datetime
  end

  def self.down
    remove_column :users, :password_salt
    remove_column :users, :persistence_token
    remove_column :users, :single_access_token
    remove_column :users, :perishable_token
    remove_column :users, :login_count
    remove_column :users, :last_login_at
    remove_column :users, :last_login_ip
  end
end


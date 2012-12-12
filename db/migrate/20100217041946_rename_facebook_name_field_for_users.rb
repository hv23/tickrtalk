class RenameFacebookNameFieldForUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :facebook_name, :name
  end

  def self.down
    rename_column :users, :name, :facebook_name
  end
end

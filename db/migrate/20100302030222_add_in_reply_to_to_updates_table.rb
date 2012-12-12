class AddInReplyToToUpdatesTable < ActiveRecord::Migration
  def self.up
    add_column :updates, :in_reply_to_update_id, :integer
    add_column :updates, :in_reply_to_user_id, :integer 
  end

  def self.down
    remove_column :updates, :in_reply_to_update_id
    remove_column :updates, :in_reply_to_user_id
  end
end

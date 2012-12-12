class AddInReplyToFieldsToPrivateUpdates < ActiveRecord::Migration
  def self.up
    add_column :private_updates, :in_reply_to_update_id, :integer
    add_column :private_updates, :in_reply_to_user, :string
  end

  def self.down
    remove_column :private_updates, :in_reply_to_update_id
    remove_column :private_updates, :in_reply_to_user
  end
end

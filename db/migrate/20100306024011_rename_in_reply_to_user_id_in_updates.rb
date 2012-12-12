class RenameInReplyToUserIdInUpdates < ActiveRecord::Migration
  def self.up
    change_column :updates, :in_reply_to_user_id, :string
    rename_column :updates, :in_reply_to_user_id, :in_reply_to_user
  end

  def self.down
    rename_column :updates, :in_reply_to_user, :in_reply_to_user_id
    change_column :updates, :in_reply_to_user_id, :interger
  end
end

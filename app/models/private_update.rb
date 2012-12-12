class PrivateUpdate
  include MongoMapper::Document  
  
  key :user_id, ObjectId
  key :private_gameroom_id, ObjectId
  key :content, String
  key :in_reply_to_update_id, String
  key :in_reply_to_user, String
  timestamps!
  
  # associations
  belongs_to :user
	belongs_to :private_gameroom
	
	# indices
  ensure_index :user_id
  ensure_index :private_gameroom_id
  ensure_index :created_at
end

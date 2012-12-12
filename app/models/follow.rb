class Follow
  include MongoMapper::Document
  
  key :follower_id, ObjectId
  key :followed_id, ObjectId
  
  # associations
  belongs_to :follower, :class_name => "User"
  belongs_to :followed, :class_name => "User"
  
  # indices
  ensure_index :follower_id
  ensure_index :followed_id
  
end

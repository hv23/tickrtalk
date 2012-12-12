class GameroomCheckin
  include MongoMapper::Document
  
  key :game_id, ObjectId
  key :user_id, ObjectId
  key :private_gameroom_id, ObjectId
  timestamps!
  
  # associations
  belongs_to :private_gameroom
  belongs_to :user
  
  # indices
  ensure_index :game_id
  ensure_index :user_id
  ensure_index :private_gameroom_id

  validates_uniqueness_of :user_id, :scope => :private_gameroom_id
  
end

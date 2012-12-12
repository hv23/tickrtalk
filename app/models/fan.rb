class Fan
  include MongoMapper::Document
  
  key :user_id, ObjectId
  key :team_id, ObjectId
    
	belongs_to :user
	belongs_to :team
	
	# indices
  ensure_index :user_id
  ensure_index :team_id
  
end

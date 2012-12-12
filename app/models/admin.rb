class Admin
  include MongoMapper::Document
  
  key :big_game_id, ObjectId
end

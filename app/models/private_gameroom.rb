class PrivateGameroom
  include MongoMapper::Document
  
  key :user_id, ObjectId
  key :game_id, ObjectId
  key :login, String
  key :gameroom_key, String
  timestamps!
  
  # associations
  many :private_updates
  many :gameroom_checkins
  belongs_to :user
  belongs_to :game
  
  # indices
  ensure_index :user_id
  ensure_index :game_id
  ensure_index :gameroom_key
  
  validates_presence_of :login
  
  def self.bitly(link)
    bitly_authorize = UrlShortener::Authorize.new 'tickrtalk', 'R_608fcb2c825c6be23181e5f16f8f9100' 
    bitly_client = UrlShortener::Client.new bitly_authorize
    bitly_shorten = bitly_client.shorten(link)
    bitly_shorten.urls
  end
end

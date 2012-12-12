class Sport
  include MongoMapper::Document  
  
  key :name, String
  key :short, String
  
  # associations
  many :teams
  many :updates
  
  # indices
  ensure_index :name
  ensure_index :short
  
  def self.get_sports
    # Rails.cache.fetch("get_sports", :expires_in => 1.week) do
	    self.all
    # end
	end

end

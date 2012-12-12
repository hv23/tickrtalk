class Update
  include MongoMapper::Document  
  include	ActionView::Helpers::JavaScriptHelper
    
  key :user_id, ObjectId
  key :game_id, ObjectId
  key :sport_id, ObjectId
  key :source, Integer
  key :sourcename, String
  key :content, String
  key :date_created, Time
  key :updated_at, Time
  key :epochdate_created, Integer
  key :linkto, String
  key :uniqueguid, Integer
  key :twitter_username, String
  key :image_url, String
  key :twitter_id, Integer
  key :in_reply_to_update_id, String
  key :in_reply_to_user, String
  key :superfeedr, Boolean
  timestamps!
  
  # associations
	belongs_to :user
	belongs_to :game
	belongs_to :sport
	
	# indices
  ensure_index :user_id
  ensure_index :game_id
  ensure_index :source
  ensure_index :date_created
	
	def self.twitter_admin_updates(game_id, search_terms)
	  current_twitter_updates = Update.all(:date_created.gte => 12.hours.ago, :game_id => game_id).collect(&:twitter_id)
	  game = Game.find(game_id)
    
    game_tweets = Twitter::Search.new(search_terms).per_page(20).fetch.results
    
    game_tweets.each do |tweet|
      unless current_twitter_updates.include?(tweet.id)
	      Update.create({:game_id => game.id, :sport_id => Sport.first(:short => game.league).id, :source => 1, :sourcename => 'Twitter',
	                    :content => tweet.text, :twitter_username => tweet.from_user, :linkto => "http://twitter.com/#{tweet.from_user}/statuses/#{tweet.id}", 
	                    :image_url => tweet.profile_image_url, :epochdate_created => Time.now.to_i, :date_created => Time.now, :twitter_id => tweet.id})
	    end
	  end
	end
	
	def self.search_twitter_path(q, from) # search_twitter_path(["Lakers", "Celtics"], ["espn", "THE_REAL_SHAQ"])
    url = "http://search.twitter.com/search.atom"
    
    q = q.join('+OR+').gsub(' ', '+')
    from = from.join('+OR+').gsub(' ', '+')
    
    path = url+"?q="+q+"+from:"+from
    path
  end
  
  def self.twitter_list(sport)
    TwitterList.all(:sport => sport).collect{|u|u.user.downcase}
  end
  
  def self.render_anywhere(partial, assigns)
    view = ActionView::Base.new(Rails::Configuration.new.view_path, assigns)
    # ActionView::Base.helper_modules.each { |helper| view.extend helper }
    # view.extend ApplicationHelper
    view.render(:partial => partial)
  end
  
  def self.parse_xml(entry)
    require 'crack/xml'
    require 'open-uri'
    
    data = Crack::XML.parse(entry)
    data
  end
	
end

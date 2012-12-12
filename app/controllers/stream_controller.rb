class StreamController < ApplicationController
	
	layout 'welcome', :except => :liveview
  before_filter :tickrtalk_credentials
  before_filter :clear_contacts
	
	def index
	  @updates = Update.all(:order => "date_created desc", :limit => 25)
	end
	
	def liveview
		@update = Update.all(:order => "date_created desc").last
		# @update.inspect
		update = Hash.new
		update[:updatecontent] = @update.content
		if @update.source == 1
			update[:updateuserlink] = @update.twitter_username
			update[:source] = 1
		elsif @update.source == 0
			update[:updateuserlink] = @update.user.username
			update[:source] = 0
		end
		update[:updategameroomlink] = @update.game_id
		update[:updategamename] = @update.game.name.strip
		render :text => update.to_json
	end
	
	def following
		if current_user
		  @followed = Follow.all(:follower_id => current_user.id)
			
			unless @followed.empty?			
				@updates = Update.all(:user_id.in => @followed.collect(&:followed_id), :order => 'date_created desc', :limit => 15)
			end
			
			@follow = true
			render :template => 'stream/index'
		else
			flash[:notice] = "You have to be logged into view your following stream."
			redirect_to '/stream'
		end
	end
end

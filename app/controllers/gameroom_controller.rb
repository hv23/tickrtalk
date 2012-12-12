class GameroomController < ApplicationController
  before_filter :tickrtalk_credentials
  before_filter :require_user, :only => [:send_to_twitter, :replies, :send_to_facebook, :following, :all_updates, :private_gameroom]
  before_filter :require_admin_user, :only => [:twitter_admin]
  before_filter :clear_contacts, :except => [:refresh_score]

	def index
	  session[:gameroom_access_time] = Time.now
	  
		gameid = params[:id]
		@game = Game.find(gameid)
		@updates = Update.paginate(:page => params[:page], :per_page => 25, :game_id => @game.id, :order => "date_created desc")
		
		if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
      @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
    end
		
		@query_string = request.query_parameters
		
    if @query_string["in_reply_to"]
      @in_reply_to = @query_string["in_reply_to"]
      @in_reply_to_update_id = @query_string["in_reply_to_update_id"]      
    end
												
    respond_to do |format|
      format.html # index.html.erb
      format.js {render :layout => false}
    end
	end
	
	def all_updates
	  session[:gameroom_access_time] = Time.now
	  
	  @game = Game.find(params[:id])
		@updates = Update.paginate(:page => params[:page], :per_page => 25, :game_id => @game.id, :order => "date_created desc")
	  
	  if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
      @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
    end
	  	  
	  respond_to do |format|
	    format.html { redirect_to '/gameroom/'+ @game.id.to_s }
      format.js {render :layout => false}
    end  
	end
	
	def replies
	  session[:gameroom_access_time] = nil	  
	  @game = Game.find(params[:id])
	  
	  if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
      @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
    end
		
		@updates = Update.paginate(:page => params[:page], :per_page => 25, :game_id => @game.id, :in_reply_to_user => current_user.username, :order => "date_created desc")
		
	  respond_to do |format|
	    format.html { redirect_to '/gameroom/'+ @game.id.to_s }
      format.js {render :layout => false}
    end  
	end
	
	def following
	  session[:gameroom_access_time] = nil
	  
	  @game = Game.find(params[:id])
	  
	  if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
      @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
    end
	  
	  @follows = Follow.all(:follower_id => current_user.id)	  
	  @updates = Update.paginate(:page => params[:page], :per_page => 25, :user_id.in => @follows.collect(&:followed_id), :game_id => @game.id, :order => "date_created desc")
		
	  respond_to do |format|
	    format.html { redirect_to '/gameroom/'+ @game.id.to_s }
      format.js {render :layout => false}
    end	  
	end
	
	def twitter_only
	  session[:gameroom_access_time] = Time.now
	  
	  @game = Game.find(params[:id])
	  @updates = Update.paginate(:page => params[:page], :per_page => 25, :game_id => @game.id, :source => 1, :order => "date_created desc")
	  
	  if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
      @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
    end

	  respond_to do |format|
	    format.html { redirect_to '/gameroom/'+ @game.id.to_s }
      format.js {render :layout => false}
    end	  
	end
	
	def tickrtalk_only
	  session[:gameroom_access_time] = nil
	
	  @game = Game.find(params[:id])
	  
	  if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
      @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
    end
	  
	  @updates = Update.paginate(:page => params[:page], :per_page => 25, :game_id => @game.id, :source => 0, :order => "date_created desc")
	  
	  respond_to do |format|
      format.html { redirect_to '/gameroom/'+ @game.id.to_s }
      format.js {render :layout => false}
    end	  
	end
	
	def private_gameroom
	  session[:gameroom_access_time] = nil
	  	  
	  @private_gameroom = PrivateGameroom.first(:gameroom_key => params[:gameroom_key])  
	  @game = Game.find(params[:id])
	  @replies_count = (current_user.replies_count.nil?) ? nil : YAML.load(current_user.replies_count)[@game.id.to_s] 
	  
	  @updates = PrivateUpdate.paginate(:page => params[:page], :per_page => 25, :private_gameroom_id => @private_gameroom.id, :order => "created_at desc")
	  @private_gameroom_key = @private_gameroom.gameroom_key
	  	  
	  @checkin = GameroomCheckin.first(:user_id => current_user.id, :private_gameroom_id => params[:private_gameroom_id])
	  
	  if @checkin
      @checkin.update_attributes(:updated_at => Time.now)
      @checkin_status = "update"
    else
      @checkin = GameroomCheckin.new({ :private_gameroom_id => params[:private_gameroom_id], :user_id => current_user.id, :game_id => params[:id] })
      @checkin.save if @checkin.valid?
      @checkin_status = "new"
    end
    
    @query_string = request.query_parameters
		
    if @query_string["in_reply_to"]
      @in_reply_to = @query_string["in_reply_to"]
      @in_reply_to_update_id = @query_string["in_reply_to_update_id"]      
    end

	  @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
	  
    respond_to do |format|
      format.html {render :layout => "gameroom_private"}
      format.js {render :layout => false}
    end
	end
	
	def send_to_twitter
    if session[:send_to_twitter].nil?
      session[:send_to_twitter] = "false"
      @send_to_twitter = "off"
    elsif session[:send_to_twitter] == "false"
      session[:send_to_twitter] = nil
      @send_to_twitter = "on"
    end
    
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def send_to_facebook
    if session[:send_to_facebook].nil?
      session[:send_to_facebook] = "false"
      @send_to_facebook = "off"
    elsif session[:send_to_facebook] == "false"
      session[:send_to_facebook] = nil
      @send_to_facebook = "on"
    end
    
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  def in_reply_to
    @game = Game.find(params[:id])
    
    if current_user
      @private_gameroom_checkins = GameroomCheckin.all(:user_id => current_user.id, :game_id => params[:id])
    end
    
	  @updates = @game.updates.all(:order => "date_created desc")
    
		@query_string = request.query_parameters
		
    if @query_string["in_reply_to"]
      @in_reply_to = @query_string["in_reply_to"]
      @in_reply_to_update_id = @query_string["in_reply_to_update_id"]      
    end
    
    respond_to do |format|
      format.html {render :action => "index"}
      format.js {render :layout => false}
    end
  end
  
  def twitter_updates
	  @game = Game.find(params[:id])
	  @updates = @game.updates.all(:source => 1, :date_created.gt => session[:gameroom_access_time], :order => "date_created desc")
	  
    unless @updates.empty? 
  	  respond_to do |format|
        format.js {render :layout => false}
      end
    else
      render :nothing => true
    end
	end
	
	def refresh_score
	  @game = Game.find(params[:id])
	  
	  respond_to do |format|
      format.js {render :layout => false}
    end
	end
	
	def twitter_admin    
    @game = Game.find(params[:game_id])

    if params[:delete_keyword] && !@game.keywords.empty?
      @game.keywords.delete(params[:keyword])
      @game.save
    end
      
    unless @game.keywords.include?(params[:search_term])
      @game.keywords << params[:search_term]
      @game.save
    end  
        
    respond_to do |format|
      format.html { redirect_to :action => "index", :id => @game.id }
    end
	end
	
	def scores_admin
	  @game = Game.find(params[:id])	  
	  @game.update_attributes(:home_score => params[:home_score], :away_score => params[:away_score])
	  
    redirect_to :action => "index", :id => @game.id
	end
end

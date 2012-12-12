class UpdateController < ApplicationController
	layout 'welcome', :except => "test"
  # layout 'test', :only => "test"
	before_filter :tickrtalk_credentials
	before_filter :require_user, :only => [:add_line]
  before_filter :clear_contacts, :except => [:twitter_updates]
	
	def view
		# get update
		@update = Update.find(params[:id])
		
		respond_to do |format|
		  format.html
      format.js {render :layout => false}
    end
	end

  def add_line
		@game = Game.find(params[:id])
		
		unless @game.league == "soccer"
		  @team = Team.first(:resource => @game.home_team.to_s)
		else
		  @team = Team.first(:openfooty_team_id => @game.openfooty_home_team_id)
		end
		
	  @sport = Sport.first(:short => @team.league.to_s)				
    @update = @game.updates.build params[:update].merge!(:user_id => current_user.id, :source => 0, :sourcename => 'TickrTalk', :sport_id => @sport.id, :epochdate_created => Time.now.to_i, :date_created => Time.now)
    
    if !@update.content.match(/@([\w]+)?/)    
      @update.in_reply_to_user = nil
      @update.in_reply_to_update_id = nil
    end
    
    @game.updates << @update
        
    @followed = Follow.all(:followed_id => current_user.id).collect(&:followed_id)
	  @followings = User.all(:id.in => @followed)
	  
    respond_to do |format|
      format.html { redirect_to :controller => "gameroom", :action => "index" }
      format.js do
        
        # replies channel
        if @update.content.match(/@([\w]+)?/)
          Orbited.send_data('game_'+@update.game_id.to_s+'_'+@update.content[/@([\w]+)?/].delete('@'), render_to_string)
          @user_in_reply = User.first(:username => @update.content[/@([\w]+)?/].delete('@'))
          
          if @user_in_reply.replies_count.nil?
            @replies_count = {}
            @replies_count[@game.id.to_s] = 1
            @user_in_reply.update_attributes({:replies_count => @replies_count.to_yaml})
            @count = 1
          else
            @current_replies = YAML.load(@user_in_reply.replies_count)
            if @current_replies.has_key?(@game.id.to_s)
              @game_replies = @current_replies.fetch(@game.id.to_s)
              @current_replies[@game.id.to_s] = @game_replies.to_i + 1
            else
              @current_replies[@game.id.to_s] = 1
            end
            @count = @current_replies[@game.id.to_s]
            @user_in_reply.update_attributes({:replies_count => @current_replies.to_yaml})
          end
            
          Orbited.send_data('game_'+@update.game_id.to_s+'_'+@update.content[/@([\w]+)?/].delete('@')+'_'+'replies_count', "$('#replies_badge').html('#{@count}')")
        end
        
        # following channel
        @followings.each do |user|
          Orbited.send_data('game_'+@update.game_id.to_s+'_'+user.username+'_following', render_to_string)
        end
        
        # gameroom channel
        Orbited.send_data('game_'+@update.game_id.to_s, render_to_string)
        render :action => "reset_form"
        
        if current_user.authorized? && session[:send_to_twitter].nil?
          if @update.content.match(/@([\w]+)?/) 
            options = {}
            @tweet = current_user.client.update(params[:update]["content"].delete('@'), options)
          else
            options = {}
            @tweet = current_user.client.update(params[:update]["content"], options)        
          end
        end
        
        if current_user.facebook_authorized? && session[:send_to_facebook].nil?
          client = FBGraph::Client.new(:client_id => FbConsumerConfig[RAILS_ENV]['application_id'], :secret_id => FbConsumerConfig[RAILS_ENV]['secret_key'], :token => current_user.facebook_token)
          fb_user = client.selection.me.info!
          
          if @update.content.match(/@([\w]+)?/) 
            client.selection.user(fb_user[:id]).feed.publish!(:message => params[:update]["content"].delete('@'))
          else
            client.selection.user(fb_user[:id]).feed.publish!(:message => params[:update]["content"])
          end
        end
        
      end
    end
  end
  
  def reset_form
    
    respond_to do |format|
      format.js {render :layout => false}
    end
  end
end

class PrivateGameroomsController < ApplicationController
  # before_filter :require_gameroom_password, :only => [:edit, :update, :show]
  before_filter :require_user
  before_filter :load_gameroom_using_gameroom_key, :only => [:show, :replies, :all_updates]
  before_filter :contacts, :only => [:find_contacts]
  before_filter :clear_contacts, :only => [:new, :index, :create, :show, :update, :edit]
  
  def new  
    @gameroom = PrivateGameroom.new 
    @game = Game.find(params[:game_id])
    
    @follows = Follow.all(:follower_id => current_user.id).collect(&:followed_id)
	  @followed = Follow.all(:followed_id => current_user.id).collect(&:follower_id)
	  
	  @user_follows = User.all(:id.in => @follows)
	  @user_followed = User.all(:id.in => @followed)
    
    respond_to do |format|
      format.js {render :layout => false}
    end
  end  
  
  def index
    @gameroom = PrivateGameroom.new  

    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create  
    @gameroom = PrivateGameroom.new(params[:private_gameroom])
    @gameroom.user_id = current_user.id
    @gameroom.gameroom_key = User.generate_gameroom_key
    @user = User.find(@gameroom.user_id)
      
    if @gameroom.valid? && @gameroom.save   
      Notifier.deliver_gameroom_invitations(@user, params[:invitees], @gameroom)
      @checkin = GameroomCheckin.new({ :private_gameroom_id => @gameroom.id, :user_id => current_user.id, :game_id => @gameroom.game_id })
      @checkin.save if @checkin.valid?
      
      # redirect_to private_gameroom_url(@gameroom, :gameroom_key  => @gameroom.gameroom_key)
      respond_to do |format|
        format.html { redirect_to '/gameroom/'+ @gameroom.game_id.to_s }
        format.js
      end
    end
  end
  
  def show
		@game = Game.find(@gameroom.game_id)
    @updates = @gameroom.private_updates.all(:ordered => "created_at desc")
    
    @query_string = request.query_parameters
		
    if @query_string["in_reply_to"]
      @in_reply_to = @query_string["in_reply_to"]
      @in_reply_to_update_id = @query_string["in_reply_to_update_id"]      
    end
    
    @checkin = GameroomCheckin.new({ :private_gameroom_id => params[:id], :user_id => current_user.id, :game_id => @gameroom.game_id })
    @checkin.save if @checkin.valid?
    
    @checkins = @gameroom.gameroom_checkins
										
    respond_to do |format|
      format.html {redirect_to "/gameroom/#{@gameroom.game_id}/private_gameroom/#{@gameroom.id}?gameroom_key=#{@gameroom.gameroom_key}" }
      format.js do
        Orbited.send_data('private_gameroom_'+@gameroom.gameroom_key.to_s, render_to_string)
      end
    end
	end
	
	def edit  
    @gameroom = PrivateGameroom.first(:gameroom_key => params[:gameroom_key]) 
    @game = Game.find(@gameroom.game_id) 

    @follows = Follow.all(:follower_id => current_user.id).collect(&:followed_id)
	  @followed = Follow.all(:followed_id => current_user.id).collect(&:follower_id)
	  
	  @user_follows = User.all(:id.in => @follows)
	  @user_followed = User.all(:id.in => @followed)
	  
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def update  
    @gameroom = PrivateGameroom.find(params[:id])  
    @user = User.find(@gameroom.user_id) 

    if @gameroom.update_attributes(params[:private_gameroom]) 
      Notifier.deliver_gameroom_invitations(@user, params[:invitees], @gameroom)   
      # flash[:notice] = "Successfully sent invitations to your gameroom."  
      respond_to do |format|
        format.html { redirect_to '/gameroom/'+ @gameroom.game_id.to_s }
        format.js
      end
    end
  end
  
  def all_updates
		@game = Game.find(@gameroom.game_id)
	  @updates = @gameroom.private_updates.all(:order => "date_created desc")
	  	  
	  respond_to do |format|
      format.js {render :layout => false}
    end  
	end
  
  def replies
	  @updates = []
	  
		@gameroom.private_updates.ordered.each do |update|
		  if update.content.include?("@#{current_user.username} ")
		    @updates << update
		  end
		end
	  	  
	  respond_to do |format|
      format.js {render :layout => "false"}
    end  
	end
	
	def update_checkins
	  @checkins = @gameroom.gameroom_checkins
	  
	  respond_to do |format|
      format.js {render :layout => false}
    end
	end
	
	def find_contacts
	  
	  respond_to do |format|
      format.js {render :layout => false}
    end
	end
	
	def fill_contacts	  	  
	  @contacts = current_user.temp_contacts
	  @contact_list = YAML.load(@contacts)
	  
	  unless params[:q].blank?
	    @fill_contacts = []
	    
		  @contact_list.each do |contact|
		    if (!contact[0].nil? && contact[0].match(/#{params[:q]}/i)) || contact[1].match(/#{params[:q]}/i)
		      @fill_contacts << contact
		    end
		  end
		  
			if @fill_contacts.empty?
				render :text => '<span style="color:#555555;">Sorry, we couldn\'t find a contact with that name.</span>'
			else
			  
			  respond_to do |format|
          format.js {render :layout => false}
        end
			end
		else
			render :nothing => true
		end
	end
	
	def add_contacts
	  @contacts = current_user.temp_contacts
	  @contact_list = YAML.load(@contacts)
	  
	  if params[:contact].match(/([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
	    @contact_input = params[:contact][/([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i]
	  end
	  
	  respond_to do |format|
      format.js {render :layout => false}
    end 
	end
	
	def add_follow
	  @follows = params[:follows] * ", "
	  
	  respond_to do |format|
      format.js {render :layout => false}
    end
	end
  
  def add_followed
    @followed = params[:followed] * ", "
	  
	  respond_to do |format|
      format.js {render :layout => false}
    end
	end
  
  private
  
  def contacts
    begin
    if params[:contact_type] == 'Gmail'
        @contacts = Contacts::Gmail.new(params[:contact_login], params[:contact_password]).contacts
        current_user.update_attributes(:temp_contacts => @contacts.to_yaml)
      elsif params[:contact_type] == 'Yahoo'
        @contacts = Contacts::Yahoo.new(params[:contact_login], params[:contact_password]).contacts
        current_user.update_attributes(:temp_contacts => @contacts.to_yaml)
      elsif params[:contact_type] == 'Hotmail'
        @contacts = Contacts::Hotmail.new(params[:contact_login], params[:contact_password]).contacts
        current_user.update_attributes(:temp_contacts => @contacts.to_yaml)
      elsif params[:contact_type] == 'AOL'
        @contacts = Contacts::Aol.new(params[:contact_login], params[:contact_password]).contacts
        current_user.update_attributes(:temp_contacts => @contacts.to_yaml)
      end
    rescue Exception => e
			@contacts = "fail"
		end
  end
  
  def load_gameroom_using_gameroom_key 
    @gameroom = PrivateGameroom.first(:gameroom_key => params[:gameroom_key])  
  
    unless @gameroom 
      flash[:notice] = "We're sorry, but this gameroom does not exist."  
      redirect_to root_url  
    end  
  end
  
end

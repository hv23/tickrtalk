class UsersController < ApplicationController
	
	layout 'user'
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update, :gamerooms]
  before_filter :clear_contacts
    
  def new  
    @user = User.new  
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end  

  def create  
    @user = User.new(params[:user])
    
    unless session[:twitter_name].nil? && session[:twitter_token].nil? && session[:twitter_secret].nil?
      @user.twitter_name = session[:twitter_name]
      @user.twitter_token = session[:twitter_token]
      @user.twitter_secret = session[:twitter_secret]
      
      session[:twitter_name] = nil
      session[:twitter_token] = nil
      session[:twitter_secret] = nil
    end
      
    unless session[:facebook_name].nil? && session[:facebook_token].nil? && session[:facebook_uid].nil?
      @user.facebook_name = session[:facebook_name]
      @user.facebook_token = session[:facebook_token]
      @user.facebook_uid = session[:facebook_uid]
      
      session[:facebook_name] = nil
      session[:facebook_token] = nil
      session[:facebook_uid] = nil
    end
      
    if @user.save
      self.current_user = @user
      @user.login_count = 1
      @user.last_login_at = Time.now
      @user.last_login_ip = request.remote_ip.to_s
      @user.save
      
      flash[:notice] = "Welcome to TickrTalk, " + @user.username + "!"  
      redirect_back_or_default root_url 
    else  
      flash.now[:error]
      render :action => "new"
    end  
  end
  
  def edit  
    @user = User.find(current_user.id)
        
    respond_to do |format|
      format.html
    end 
  end  
    
  def update  
    @user = current_user
    
      
    @user.attributes = params[:user]
    
    if !params[:user][:password].nil? && !params[:user][:password].blank?
      if @user.save
        flash[:notice] = "Successfully updated profile."  
        redirect_to account_url  
      else  
        flash.now[:error]
        render :action => 'edit'  
      end
    else  
      if @user.save(:validate => false)
        flash[:notice] = "Successfully updated profile."  
        redirect_to account_url  
      else  
        flash.now[:error]
        render :action => 'edit'  
      end
    end
  end 
	
	def show
		username = params[:id]
		# get the user
		
		@user = User.first(:username => username)
		
		unless @user.nil?
	
  		# find users' updates
  		@updates = Update.paginate(:page => params[:page], :per_page => 25, :user_id => @user.id, :order => 'date_created desc')
	
  		# find user's followers
  		@followers = Follow.all(:followed_id => @user.id)
	
  		# find user's followings
  		@following = Follow.all(:follower_id => @user.id)
	
  		if current_user
  		if current_user.id != @user.id
  			# get our current following	status
  			followcheck = Follow.first(:follower_id => current_user.id, :followed_id => @user.id)
  			if followcheck.nil?
  				@isfollowing = false
  				@followingtext = 'Follow'
  			else
  				@isfollowing = true
  				@followingtext = 'Unfollow'
  			end
  		else
  			@isfollowing = false
  		end
  		else
  			@isfollowing = false;
  		end	
  	end
		
		if @user.nil?
	    redirect_to root_url
	    flash[:notice] = "Sorry dude, but user #{params[:id]} doesn't exist."
	  else		
  		respond_to do |format|
        format.html
        format.js
      end
    end
	end
	
	def gamerooms
	  @private_gamerooms = GameroomCheckin.all(:user_id => current_user.id, :limit => 10, :order => 'id DESC')
    
	  respond_to do |format|
      format.html
    end
	end
	
	def togglefollow
		# get current following status
		userid = params[:id]
		@follow_status = params[:follow_status]
		
		#check logged.in
		if current_user
			#check that the person isn't the same
			if current_user.id == userid
				render :text => 'You can\'t follow yourself.'
			else
				# okay now check the current status of this person following this other person
				followstat = Follow.first(:follower_id => current_user.id, :followed_id => userid)
				if followstat.nil?
					# now we should follow them
										
					newfollow = Follow.create({:follower_id => current_user.id, :followed_id => userid})
          # newfollow.save
					
          # render :text => 'Unfollow'
					@followingtext = 'Unfollow'
				else
					followdelete = Follow.destroy(followstat.id)
          # render :text => 'Follow'
					@followingtext = 'Follow'
				end
			end
		end
		
		respond_to do |format|
		  format.html {redirect_to :action => "show", :id => params[:id]}
      format.js {render :layout => false}
    end
	end
	
	def fan
		if current_user
			teamid = params[:id]
			fancheck = Fan.first(:user_id => current_user.id, :team_id => teamid)
			if fancheck.nil?
				team = Team.find(teamid)
				newfan = Fan.create({:user_id => current_user.id, :team_id => teamid})
								
				redirect_to :back
			else
				# delete fanship
				Fan.destroy(fancheck.id)
				
				redirect_to :back
			end
		end
	end
	
end

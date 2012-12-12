class UserSessionsController < ApplicationController
  layout "user"
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  before_filter :clear_contacts
  
  def new
    @user = User.new   
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def create
    if request.post?
      if session[:user] = User.authenticate(params[:user][:username], params[:user][:password])
        @user = User.first(:username => params[:user][:username])   
        self.current_user = @user
        
        if @user.login_count.nil?
          @user.login_count = 1
          @user.last_login_at = Time.now
          @user.last_login_ip = request.remote_ip.to_s
          @user.save
        else
          @user.login_count = @user.login_count + 1
          @user.last_login_at = Time.now
          @user.last_login_ip = request.remote_ip.to_s
          @user.save
        end
        
        flash[:message]  = "Login successful!"
        redirect_back_or_default root_url
      else
        flash.now[:error] = "Your username or password are incorrect."
        render :action => "new"
      end
    end  
  end
  
  def destroy  
    current_user.update_attributes(:twitter_token => nil)
    current_user.update_attributes(:twitter_secret => nil)
    current_user.update_attributes(:facebook_token => nil)
    
    session[:user] = nil
    
    # unless @private_gameroom_session.nil?    
    #   @private_gameroom_session = PrivateGameroomSession.find  
    #   @private_gameroom_session.destroy
    # end
    
    # Old facebook connect stuff  
    # clear_fb_cookies!
    # clear_facebook_session_information
    # facebook_session.user = nil
      
    reset_session
    # session[:facebook_session] = nil
    # session[:facebook_uid] = nil
    
    flash[:notice] = "You have been logged out."  
    redirect_to root_url
  end
end

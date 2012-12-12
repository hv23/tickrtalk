class SessionsController < ApplicationController
  layout "user"
  before_filter :clear_contacts
  
  def new
  end
  
  def create
    oauth.set_callback_url(finalize_session_url)
    
    session['rtoken']  = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret
    
    redirect_to oauth.request_token.authorize_url
  end
  
  def destroy
    reset_session
    redirect_back_or root_path
  end
  
  def logout_twitter
    if current_user
      current_user.update_attributes(:twitter_token => nil)
      current_user.update_attributes(:twitter_secret => nil)
    end
    
    session[:twitter_name] = nil
    session[:twitter_token] = nil
    session[:twitter_secret] = nil
    redirect_back_or_default(root_url)
  end
  
  def finalize
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:oauth_verifier])
    
    session['rtoken']  = nil
    session['rsecret'] = nil
    
    profile = Twitter::Base.new(oauth).verify_credentials
    
    unless current_user
      user = User.first(:twitter_name => profile.screen_name)
      
      # send user to tickrtalk_credentials or login
      if user.nil?
        session[:twitter_name] = profile.screen_name
        session[:twitter_token] = oauth.access_token.token
        session[:twitter_secret] = oauth.access_token.secret
        redirect_to twitter_signup_path
      else     
        user.update_attributes(:twitter_token => oauth.access_token.token)
        user.update_attributes(:twitter_secret => oauth.access_token.secret)
        
        self.current_user = user
        sign_in(user)        
        
        if current_user 
          flash[:notice] = "Welcome back, " + user.username + "!" 
          redirect_back_or_default(root_url)
        else  
          flash.now[:error]
          redirect_to login_path 
        end
      end
          
    else 
      user = User.find(current_user.id)
      user.update_attributes(:twitter_name => profile.screen_name)  
      user.update_attributes(:twitter_token => oauth.access_token.token)
      user.update_attributes(:twitter_secret => oauth.access_token.secret)
            
      sign_in(user)
      redirect_back_or_default(root_url)
    end
  end
  
  def twitter_signup
    @user = User.new  
  end
  
  def facebook_create
    redirect_to facebook_oauth.authorization.authorize_url(:redirect_uri => FbConsumerConfig[RAILS_ENV]['callback_url'], :scope => 'publish_stream,offline_access')
  end
  
  def facebook_publish_permissions
    redirect_to facebook_oauth.authorize_url(:display => "popup")
  end
  
  def facebook_finalize    
    if params[:code]
      access_token = facebook_oauth.authorization.process_callback(params[:code], :redirect_uri => FbConsumerConfig[RAILS_ENV]['callback_url'])
      session[:access_token] = access_token
      profile = facebook_oauth.selection.me.info!
    
      unless current_user
        user = User.first(:facebook_uid => profile[:id])
      
        # send user to tickrtalk_credentials or login
        if user.nil?
          session[:facebook_name] = profile[:name]
          session[:facebook_token] = access_token
          session[:facebook_uid] = profile[:id]
          redirect_to facebook_signup_path
        else     
          user.update_attributes(:facebook_token => access_token)
        
          self.current_user = user
          sign_in(user)        
        
          if current_user 
            flash[:notice] = "Welcome back, " + user.username + "!" 
            redirect_back_or_default(root_url)
          else  
            flash.now[:error]
            redirect_to login_path 
          end
        end
          
      else 
        user = User.find(current_user.id)
        user.update_attributes(:facebook_uid => profile[:id])  
        user.update_attributes(:facebook_name => profile[:name])  
        user.update_attributes(:facebook_token => access_token)
            
        sign_in(user)
        redirect_back_or_default(root_url)
      end
    elsif !params[:code] && current_user
      redirect_to root_url
    else
      flash[:error] = "Simply fill out this form instead of logging in with Facebook."
      redirect_to signup_path
    end
  end
  
  def facebook_signup
      @user = User.new  
        
    # unless current_user
    #   user = User.first(:facebook_uid => facebook_session.user.uid)
    #   
    #   if user.nil?
    #     session[:facebook_uid] = facebook_session.user.uid
    #     
    #     @user = User.new
    #   else
    #     self.current_user = user
    #     session[:user_id] = user.id
    #     user.update_attributes(:facebook_session_key => facebook_session.session_key)
    #     
    #     if current_user
    #       flash[:notice] = "Welcome back, " + user.username + "!" 
    #       redirect_back_or_default(root_url)
    #     else
    #       flash.now[:error]
    #       redirect_to login_path
    #     end
    #   end
    # else 
    #   user = User.find(current_user.id)
    #   user.update_attributes(:facebook_uid => facebook_session.user.uid)  
    #   user.update_attributes(:name => facebook_session.user.name)  
    #   user.update_attributes(:facebook_session_key => facebook_session.session_key)
    #         
    #   session[:user_id] = user.id
    #   redirect_back_or_default(root_url)
    #end
    
  end
  
  def logout_facebook
    # Old facebook connect
    # clear_fb_cookies!
    # clear_facebook_session_information
    # reset_session
    
    if current_user
      current_user.update_attributes(:facebook_token => nil)
    end
    
    session[:facebook_name] = nil
    session[:facebook_uid] = nil
    session[:facebook_token] = nil
    redirect_back_or_default(root_url)
  end
  
  private
  
  def oauth
    @oauth ||= Twitter::OAuth.new(ConsumerConfig['token'], ConsumerConfig['secret'], :sign_in => true)
  end
  
end

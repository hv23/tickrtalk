# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  include Twitter::AuthenticationHelpers
  helper :all # include all helpers, all the time
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8d52ca6c7b35f59b46f8049573eb1dc7'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :password_confirmation, :fb_sig_friends
  helper_method :rel_date, :rel_time, :store_location
  before_filter :set_user_time_zone
  # before_filter :create_facebook_session
  # helper_method :facebook_session
  rescue_from Twitter::Unauthorized, :with => :twitter_force_sign_in
  # rescue_from Facebooker::Session::SessionExpired, :with => :facebook_session_expired
  
  private
  
  def facebook_oauth
    unless session[:facebook_token]
      @facebook_oauth ||= FBGraph::Client.new(:client_id => FbConsumerConfig[RAILS_ENV]['application_id'], :secret_id => FbConsumerConfig[RAILS_ENV]['secret_key'])
    else
      @facebook_oauth ||= FBGraph::Client.new(:client_id => FbConsumerConfig[RAILS_ENV]['application_id'], :secret_id => FbConsumerConfig[RAILS_ENV]['secret_key'], :token => session[:facebook_token])
    end
  end
  
  def clear_contacts
    if current_user
      @user = User.find(session[:user_id])
      @user.temp_contacts = nil
      @user.save
    end
  end
 
  # def current_user_session  
  #   return @current_user_session if defined?(@current_user_session)  
  #   @current_user_session = UserSession.find  
  # end  
  #  
  # def current_user  
  #   return @current_user if defined?(@current_user)
  #   @current_user = current_user_session && current_user_session.user 
  # end
  # 
  # def require_user
  #   unless current_user
  #     store_location
  #     flash[:notice] = "You must be logged in to access this page."
  #     redirect_to new_user_session_url
  #     return false
  #   end
  # end 
  # 
  # def require_no_user
  #   if current_user
  #     store_location
  #     flash[:notice] = "You must be logged out to access this page."
  #     redirect_to account_url
  #     return false
  #   end
  # end
  
  def twitter_force_sign_in(exception)
    reset_session
    flash[:error] = 'Seems your credentials are not good anymore. Please sign in again.'
    redirect_to new_session_path
  end
  
  def tickrtalk_credentials
    # checks that Twitter/Facebook user has Tickrtalk credentials
    if session[:twitter_name]
      flash[:notice] = "You need register with Tickrtalk."
      redirect_to twitter_signup_path
    elsif session[:facebook_uid]
        flash[:notice] = "You need register with Tickrtalk."
        redirect_to facebook_signup_path
    end
  end
  
  # def user_facebook_connect
  #   if current_user && facebook_session
  #     user = User.find(@current_user)
  #     user.facebook_uid = facebook_session.user.uid
  #     flash[:notice] = "You are connected through Facebook as #{facebook_session.user}."
  #   end
  # end
  
  # # private gameroom authentication
  
  # def private_gameroom_session  
  #   return @private_gameroom_session if defined?(@private_gameroom_session) && @private_gameroom_session.game_id == PrivateGameroom.find_by_gameroom_key(params[:gameroom_key]).game_id
  #   @private_gameroom_session = PrivateGameroomSession.find  
  # end  
  #  
  # def private_gameroom 
  #   return @private_gameroom if defined?(@private_gameroom)
  #   @private_gameroom = private_gameroom_session && private_gameroom_session.private_gameroom
  # end
  
  # def require_gameroom_password
  #   unless private_gameroom 
  #     #&& private_gameroom_session == PrivateGameroom.find_by_gameroom_key(params[:gameroom_key]).game_id
  #     store_location
  #     flash[:notice] = "You must be logged in to this gameroom."
  #     redirect_to new_private_gameroom_session_url(:gameroom_key => params[:gameroom_key])
  #     return false
  #   end
  # end
  # 
  # def require_no_gameroom_password
  #   if private_gameroom
  #     store_location
  #     flash[:notice] = "You must be logged out to access this page."
  #     redirect_to private_gameroom_url(:gameroom_key => params[:gameroom_key])
  #     return false
  #   end
  # end

	def rel_date(date)
		date = Date.parse(date, true) unless /Date.*/ =~ date.class.to_s
		#date = Date.parse(date, true)
		days = (date - Date.today).to_i
	   
		return 'today'     if days >= 0 and days < 1
		return 'tomorrow'  if days >= 1 and days < 2
		return 'yesterday' if days >= -1 and days < 0

		return "in #{days} days"      if days.abs < 60 and days > 0
		return "#{days.abs} days ago" if days.abs < 60 and days < 0
	
		return date.strftime('%A, %B %e') if days.abs < 182
	  	return date.strftime('%A, %B %e, %Y')
	end
	
	def plural(num)
		if num != 1
			return "s"
		end
	end
	
	def rel_time(date)
		# we are given a DateTime object.
		# convert it to a UNIX epoch
		epochdate = date.to_i
		
		# now that we have that, let's...
		diff = Time.now.to_i - epochdate
		
		diff = diff * -1
		
		if (diff<60)
			return diff + ' second' + plural(diff) + ' ago'
		end
		
		diff = (diff/60).round
		
		if (diff<60)
			return diff + ' minute' + plural(diff) + ' ago'
		end
		
		diff = (diff/60).round
		
		if (diff<24)
			return diff + ' hour' + plural(diff) + ' ago'
		end
		
		diff = (diff/24).round
		
		if (diff<7)
			return diff + ' day' + plural(diff) + ' ago'
		end
		
		diff = (diff/7).round
		
		if (diff<4)
			return diff + ' week' + plural(diff) + ' ago'
		end
	end
	
  # def facebook_oauth
  #     @facebook_oauth = FBGraph::Client.new(:application_id => FbConsumerConfig[RAILS_ENV]['application_id'], :application_secret => FbConsumerConfig[RAILS_ENV]['secret_key'], :callback => FbConsumerConfig[RAILS_ENV]['callback_url'])
  #   end
  
  # Facebook Connect stuff - delete soon
  # def facebook_session_expired
  #   clear_fb_cookies!
  #   clear_facebook_session_information
  #   return_to = session[:return_to]
  #   reset_session # remove your cookies!
  #   session[:return_to] = return_to
  #   flash[:error] = "Your facebook session has expired."
  # end
  # 
  # def status_updates_allowed?
  #   res = facebook_session.fql_query("select status_update from permissions where uid == #{facebook_session.user.uid}")
  #   if res.join =~ /status_update1/
  #     return true
  #   else
  #     return false
  #   end
  # end
end

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8d52ca6c7b35f59b46f8049573eb1dc7'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  helper :all # include all helpers, all the time
  
  helper_method :current_user, :current_user, :rel_date, :rel_time

  before_filter :set_user_time_zone
 
  def current_user
    @current_user ||= ((session[:user_id] && User.find_by_id(session[:user_id])) || 0)
  end
 
  def current_user()
    current_user != 0
  end

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
	
	def set_user_time_zone
		#Time.zone = current_user.time_zone if current_user
		#Time.zone = "Eastern Time (US & Canada)"
		if current_user
			Time.zone = current_user.time_zone
		else
			Time.zone = "Eastern Time (US & Canada)"
		end
	end

end

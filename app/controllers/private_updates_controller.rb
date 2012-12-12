class PrivateUpdatesController < ApplicationController
	layout 'welcome'
	before_filter :require_user, :only => [:add_line]
  before_filter :load_gameroom_using_gameroom_key
  before_filter :clear_contacts

	def show
		# get update
		@update = PrivateUpdate.find(params[:id])
		
		respond_to do |format|
		  format.html
      format.js {render :layout => false}
    end
	end

  def add_line
    @update = @gameroom.private_updates.build params[:update].merge!(:user_id => current_user.id)
    
    if !@update.content.match(/@([\w]+)?/)    
      @update.in_reply_to_user = nil
      @update.in_reply_to_update_id = nil
    end
      
    # if @update.content.include?("@"+current_user.username)  
    #   @screen_name = current_user.username
    # else
    #   return false
    # end
    
    @gameroom.private_updates << @update
    @updates = @gameroom.private_updates

    respond_to do |format|
      format.html { redirect_to private_gameroom_url(@gameroom, :gameroom_key => @gameroom.gameroom_key) }
      format.js do

        # replies channel
        # if @update.content.match(/@([\w]+)?/)
        #   @is_reply = true
        #   Orbited.send_data('private_gameroom_'+@gameroom.gameroom_key.to_s+'_'+@update.content[/@([\w]+)?/].delete('@'), render_to_string)
        # end

        # gameroom channel        
        Orbited.send_data('private_gameroom_'+@gameroom.gameroom_key.to_s, render_to_string)               
        render :action => "reset_form"
      end
    end
  end

  def reset_form

    respond_to do |format|
      format.js {render :layout => false}
    end
  end
  
  private
  
  def load_gameroom_using_gameroom_key 
    @gameroom = PrivateGameroom.first(:gameroom_key => params[:gameroom_key])  
  
    unless @gameroom 
      flash[:notice] = "We're sorry, but this gameroom does not exist."  
      redirect_to root_url  
    end  
  end
  
end

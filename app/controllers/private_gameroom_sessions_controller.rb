class PrivateGameroomSessionsController < ApplicationController
  # before_filter :load_gameroom_using_gameroom_key
  before_filter :require_no_gameroom_password, :only => [:new, :create]
  before_filter :require_gameroom_password, :only => :destroy
  layout "welcome"
  
  def new  
    @private_gameroom_session = PrivateGameroomSession.new
    @gameroom = PrivateGameroom.find_by_gameroom_key(params[:gameroom_key])    
  end
  
  def create  
    @private_gameroom_session = PrivateGameroomSession.new(params[:private_gameroom_session])
    @gameroom = PrivateGameroom.find_by_gameroom_key(params[:private_gameroom_session][:gameroom_key])    
          
    if @private_gameroom_session.save       
      @private_gameroom_session.game_id = @gameroom.game_id
      flash[:notice] = "You have logged into a private gameroom!"        
      redirect_to private_gameroom_url(@gameroom, :gameroom_key  => @gameroom.gameroom_key)
    else  
      flash.now[:error]
      render :action => "new"
    end  
  end
  
  def destroy  
    @private_gameroom_session = PrivateGameroomSession.find  
    @private_gameroom_session.destroy 
    reset_session
    flash[:notice] = "You have been logged out of this private gameroom."  
    redirect_to root_url 
  end
  
  # private
  # 
  # def load_gameroom_using_gameroom_key 
  #   @gameroom = PrivateGameroom.find_by_gameroom_key(params[:gameroom_key])  
  # 
  #   unless @gameroom 
  #     flash[:notice] = "We're sorry, but this is an invalid gameroom."  
  #     redirect_to root_url  
  #   end  
  # end
end

class TasksController < ApplicationController
  
  def update_twitter
    Update.twitter_updates
    render :nothing => true, :layout => false
  end 
  
  def update_games
    Game.update_games    
    render :nothing => true, :layout => false
  end
  
  def update_games_hourly
    Game.update_games_hourly    
    render :nothing => true, :layout => false
  end
  
  def update_slow_games
    Game.update_slow_games    
    render :nothing => true, :layout => false
  end
  
  def update_slow_games_hourly
    Game.update_slow_games_hourly
    render :nothing => true, :layout => false
  end
  
  def update_openfooty
    Game.update_openfooty
    render :nothing => true, :layout => false
  end
    
end

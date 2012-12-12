class WelcomeController < ApplicationController
  before_filter :tickrtalk_credentials
  before_filter :clear_contacts
	layout 'welcome', :except => [:ticker]
  
	def index
    @currentgames = Game.current_games
		@upcominggames = Game.upcoming_games
    @recent_updates = Update.paginate(:page => params[:page], :per_page => 25, :order => "date_created desc")
    
    @admin = Admin.first
    
    if !@admin.nil?
      @big_game = Game.find(@admin.big_game_id)
    else
      @big_game = nil
    end
    		
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
  
  def stream
    @update = Update.all(:limit => 1, :order => "id")

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

	def ticker
		# get last few
		@updates = Update.all(:limit => 10, :order => "date_created desc")
		
    # respond_to do |format|
    #   format.js {render :layout => false}
    # end
  end
end


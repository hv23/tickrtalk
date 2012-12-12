class GamesController < ApplicationController
	layout 'welcome', :except => [:quicksearch, :big_game_search]
  before_filter :tickrtalk_credentials
  before_filter :clear_contacts
	
	def index
	  if params[:league]
	    @games = Game.paginate(:per_page => 25, :page => params[:page], :order => "game_datetime", :league => params[:league], :game_datetime.gt => Time.zone.now-6.hours)
		else
		  @games = Game.paginate(:per_page => 25, :page => params[:page], :order => "game_datetime", :game_datetime.gt => Time.zone.now-6.hours)
		end
		
		@leagues = Sport.all		
	end
	
	def quicksearch
		unless params[:q].blank?
		  @games = Game.all(:name => /#{params[:q]}/i, :game_datetime.gt => Time.zone.now-6.hours, :order => "game_datetime", :limit => 15)
			if @games.empty?
				render :text => '<span style="color:#555555;">Sorry, we couldn\'t find an upcoming game with that search query.<br />If you\'re putting the full team name, try &quot;Yankees&quot; instead of &quot;New York Yankees&quot;.</span>'
			end
		else
			render :nothing => true
		end
	end
	
	def big_game_search
		unless params[:q].blank?
		  @games = Game.all(:name => /#{params[:q]}/i, :game_datetime.gt => Time.zone.now-6.hours, :order => "game_datetime", :limit => 15)
			if @games.empty?
				render :text => '<span style="color:#555555;">Sorry, we couldn\'t find an upcoming game with that search query.<br />If you\'re putting the full team name, try &quot;Yankees&quot; instead of &quot;New York Yankees&quot;.</span>'
			else
			  respond_to do |format|
          format.js {render :layout => false}
        end
      end
      
		else
			render :nothing => true
		end
	end
	
	def add_big_game
	  if params[:game_id]
	    @game_id = params[:game_id]
	    
	    @admin = Admin.first
	    
	    if @admin.nil?
	      @admin = Admin.new
	    end
	    
	    @admin.big_game_id = @game_id
	    @admin.save
	  end
	  
    redirect_to :controller => "admin", :action => "index"
	end
end

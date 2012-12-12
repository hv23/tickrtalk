class TeamsController < ApplicationController
	
	layout 'welcome', :except => :quicksearch
  before_filter :tickrtalk_credentials
  before_filter :clear_contacts
  
  caches_page :league
	
	def index
	  @gamesnow = Game.all(:status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-6.hours, '$lt' => Time.zone.now }, :order => "game_datetime", :limit => 15)
		# get up to 15 games that are upcoming
		@gamesupcoming = Game.all(:game_datetime.gt => Time.zone.now, :order => "game_datetime", :limit => 15)
								
		@leagues = Sport.all
	end
	
	def view
		@teamid = params[:id]
		@team = Team.find(@teamid)
    
    if @team.league == "soccer"
      @games = Game.where('$where' => "this.home_team_id == '#{@team.id}' || this.away_team_id == '#{@team.id}'", :game_datetime.gte => 1.day.ago, :game_datetime.lte => 1.month.from_now).sort(:game_datetime).limit(10)
      @all_games = Game.where('$where' => "this.home_team_id == '#{@team.id}' || this.away_team_id == '#{@team.id}'").sort(:game_datetime).limit(10)
		else
      @games = Game.where('$where' => "this.home_team_id == '#{@team.id}' || this.away_team_id == '#{@team.id}'", :status => { '$ne' => /FINAL/i }, :game_datetime.gte => 1.day.ago, :game_datetime.lte => 1.month.from_now).sort(:game_datetime).limit(10).all
      @all_games = Game.where('$where' => "this.home_team_id == '#{@team.id}' || this.away_team_id == '#{@team.id}'", :game_datetime.lte => 1.hour.from_now, :game_datetime.gte => 1.month.ago).sort(:game_datetime).limit(20).all
		end
				
    @updates = Update.paginate(:game_id => { "$in" => @all_games.collect(&:id) }, :page => params[:page], :per_page => 25, :order => "date_created desc")   
		@fans = Fan.all(:team_id => @teamid)
		
		if current_user
			@fanship = Fan.first(:user_id => current_user.id, :team_id => @teamid)
		end
		
		respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
	end
	
	def quicksearch
		unless params[:q].blank?
			@teams = Team.all(:team_name => /#{params[:q]}/i, :order => "team_name", :limit => 12)
			if @teams.empty?
				render :text => '<span style="color:#555555;">Sorry, we couldn\'t find a team with that name.<br />If you\'re putting the full team name, try &quot;Yankees&quot; instead of &quot;New York Yankees&quot;.</span>'
			end
		else
			render :nothing => true
		end
	end
	
	def league		
		@teams = Team.paginate(:page => params[:page], :order => 'team ASC', :conditions => { :league => params[:id] })
	end
end

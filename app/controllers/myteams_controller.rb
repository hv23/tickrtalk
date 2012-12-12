class MyteamsController < ApplicationController
	
	layout 'user', :except => [:autocomplete, :addteam]
  before_filter :require_user
  before_filter :tickrtalk_credentials, :only => [:index]
  before_filter :clear_contacts
  after_filter :clear_teams_cache, :only => [:addteam, :removeteam]
	
	def index
		# we need to get all of the persons' teams that they are a fan of
		# need to refactor this code; use $in
		@fanof = Fan.all(:user_id => current_user.id)
		@teams = @fanof.collect(&:team_id)
		
		@home_games = Game.all(:home_team_id.in => @teams, :game_datetime => { '$gte' => Time.zone.now }, :order => "game_datetime", :limit => 15)
		@away_games = Game.all(:away_team_id.in => @teams, :game_datetime => { '$gte' => Time.zone.now }, :order => "game_datetime", :limit => 15)
		
    @games = []
    @games << @home_games
    @games << @away_games
    @games.flatten!
    
    @games = @games.sort_by(&:game_datetime)

    # @fanof.each do |f|
    #   
    #   game = Game.all('$where' => "this.home_team_id == '#{f.team_id}' || this.away_team_id == '#{f.team_id}'", :game_datetime => { '$gte' => Time.zone.now }, :order => "game_datetime", :limit => 30)
    #   
    #   unless game.empty?
    #     @games << game
    #       end
    #       
    #       @games.each do |game|
    #         @upcoming = game
    #       end
    # end
	  	  
	  respond_to do |format|
		  format.html
    end
	end
	
	def edit
		# get all of this users' teams
		@user = User.find(current_user.id)
		
		@fans = Fan.all(:user_id => @user.id).collect(&:team_id)
		@teams = Team.all(:id.in => @fans)
	end
	
	def autocomplete
    # sq = params[:q]
    unless params[:q].blank?
			@values = Team.all(:team_name => /#{params[:q]}/i, :order => "team_name")
      if @values.empty?
        render :text => '<span style="color:#555555;">Sorry, we couldn\'t find a team with that name.<br />If you\'re putting the full team name, try &quot;Yankees&quot; instead of &quot;New York Yankees&quot;.</span>'
      end
    else
      render :nothing => true
    end
    # @values = Team.find(:all, :conditions => ["team_name LIKE ? OR team LIKE ? OR mascot LIKE ?", sq + "%", sq + "%", sq + "%"])
  end
	
	def addteam
	  @user = User.find(current_user.id)
		
		@fans = Fan.all(:user_id => @user.id).collect(&:team_id)
		@teams = Team.all(:id.in => @fans)
		
		teamid = params[:id]
		@team = Team.find(teamid)
	
		# check if a fan for this is already in here
		checkfan = Fan.first(:user_id => current_user.id, :team_id => teamid)
	
		if checkfan.nil?
			# make a new fan
			fan = {}
			fan[:user_id] = current_user.id
			fan[:team_id] = teamid
			fan[:sport_id] = @team.sport_id
			fan[:date_created] = Time.now
	
			newfan = Fan.create(fan)
						
			respond_to do |format|
			  format.html { render :layout => false }
  		end
		end
	end
	
	def removeteam
	# remove the team
		@teamid = params[:id]
		# get the row
		@fanrow = Fan.first(:user_id => current_user.id, :team_id => @teamid)
		unless @fanrow.nil?
			Fan.destroy(@fanrow.id)			
		end
				
		respond_to do |format|
		  format.html { redirect_to :controller => "myteams", :action => "edit", :id => current_user.id }
		  format.js
		end
	end
	
	private
	
	def clear_teams_cache
	  expire_page :controller => 'teams', :action => 'league'  
	end
end

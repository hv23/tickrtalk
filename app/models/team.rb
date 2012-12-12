class Team
  include MongoMapper::Document  
  
  key :sport_id, ObjectId
  key :team_name, String
  key :team, String
  key :mascot, String
  key :league, String
  key :resource, String
  key :resource_path, String
  key :openfooty_team_id, Integer
  key :openfooty_team, String
  key :openfooty_league_id, Integer
  key :openfooty_league, String
  key :badge, String
  
  # associations
  many :fans
  belongs_to :sport
  
  # indices
  ensure_index :sport_id
  ensure_index :league
  ensure_index :team_name
  ensure_index :resource_path
  ensure_index :openfooty_team_id
  ensure_index :openfooty_league_id	
	
	def title
		tname = ''
		tname += team.gsub(/&/,'&')
		unless mascot.nil?
			tname += ' ' + mascot
		end
		return tname.strip
	end
	
	def self.create_worldcup_teams(league_id)
	  # must use openfooty gem version 0.2.0 for this; for some reason, the xml does not have team_id
	  
	  teams = openfooty.league("getTeams", :league_id => league_id).openfooty.teams.team
		teams.each do |team|
			teamids = Team.all(:openfooty_league_id => league_id).collect(&:openfooty_team_id)
			unless teamids.include?(team.id.to_i)
        Team.create(:sport_id => Sport.first(:name => 'soccer').id, :team_name => team.cdata, :team => team.cdata, :mascot => team.cdata,
                    :league => "soccer", :openfooty_team_id => team.id, :openfooty_team => team.cdata, :openfooty_league_id => league_id,
                    :openfooty_league => "world cup")
			end
		end
		sleep 2
	  
	end
	
	def games
		# find all games with the id
		games = Game.find(:all, :conditions =>["team1id = ? OR team2id = ?", id, id])
		return games
	end
	
  
	
	def self.load_teams
		Team.connection.execute "TRUNCATE TABLE teams"
		Team.connection.execute "LOAD DATA LOCAL INFILE '#{RAILS_ROOT}/bin/teams.csv' INTO TABLE tickrtalk_development.teams FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (team_name, team, mascot, league, resource, resource_path)"
	end
	
	def self.openfooty
	  @openfooty = Openfooty::Client.new
	end
	
end

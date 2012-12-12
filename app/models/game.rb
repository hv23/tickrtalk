class Game
  include MongoMapper::Document  
  
  key :date, Date
  key :time, Time
  key :name, String
  key :league, String
  key :home_score, Integer
  key :home_team, String
  key :home_team_id, ObjectId
  key :home_winlose, String
  key :away_score, Integer
  key :away_team, String
  key :away_team_id, ObjectId
  key :away_winlose, String
  key :status, String
  key :resource_text, String
  key :game_datetime, Time
  key :openfooty_match_id, Integer
  key :openfooty_home_team_id, Integer
  key :openfooty_away_team_id, Integer
  key :openfooty_league_id, Integer
  key :openfooty_league, String
  key :openfooty_status, String
  key :openfooty_ft_score, String
  key :openfooty_winner, String
  key :keywords, Array    
  
  # associations
  many :updates
  
  # indices
  ensure_index :game_datetime
  ensure_index :league
  ensure_index :home_team
  ensure_index :away_team
  ensure_index :home_team_id
  ensure_index :away_team_id
  ensure_index :status
  ensure_index :resource_text  
  ensure_index :openfooty_home_team_id
  ensure_index :openfooty_away_team_id
  ensure_index :openfooty_league_id
  ensure_index :openfooty_match_id
  
  def self.redo_ids
    games = Game.where(:openfooty_match_id => nil).all
    teams = Team.where(:openfooty_team_id => nil).all
  
    games.each do |game|
      teams.each do |team|
        if team.resource == game.home_team
          game.home_team_id = team.id
          game.save
        elsif team.resource == game.away_team  
          game.away_team_id = team.id
          game.save
        end
      end
    end
  end
  
  def self.redo_soccer_ids
    games = Game.where(:openfooty_match_id.ne => nil).all
    teams = Team.where(:openfooty_team_id.ne => nil).all
  
    games.each do |game|
      teams.each do |team|
        if team.openfooty_team_id == game.openfooty_home_team_id
          game.home_team_id = team.id
          game.save
        elsif team.openfooty_team_id == game.openfooty_away_team_id
          game.away_team_id = team.id
          game.save
        end
      end
    end
  end
	
  def self.current_games
    Rails.cache.fetch("current_games", :expires_in => 15.minutes) do
      self.all(:status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-6.hours, '$lt' => Time.zone.now }, :order => "game_datetime", :limit => 15)    
    end
  end
  
  def self.upcoming_games
    Rails.cache.fetch("upcoming_games", :expires_in => 30.minutes) do
      self.all(:game_datetime.gt => Time.zone.now, :order => "game_datetime", :limit => 15)
    end
  end
	
	def self.create_pro_games
	  teams = Team.all(:league.ne => 'ncaaf', :league.ne => 'ncaab')
		teams.each do |team|
			begin
				games = fanfeedr.schedule(:resource => team.resource.to_s)
				games.each do |g|
  				resource_paths = Game.all('$where' => "this.home_team == '#{team.resource.to_s}' || this.away_team == '#{team.resource.to_s}'").collect(&:resource_text)
          # resource_paths = Game.find(:all).collect(&:resource_text)
					unless resource_paths.include?(g["resource_text"])
						Game.create(:date => g["date"], :time => g["time"], :name => g["name"], :league => Team.first(:resource => g["home"]["team"]).league, :home_score => g["home"]["score"], 
												:home_team => g["home"]["team"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], :away_team => g["away"]["team"], 
												:away_winlose => g["away"]["winlose"], :status => g["status"], :resource_text => g["resource_text"], :game_datetime => g["date"].to_s+" "+g["time"].to_s)
					end
				end
				sleep 2
				
			rescue Exception => e
				puts 'RESCUED!'
			end
		end
	end
	
	def self.create_ncaaf_games
	  teams = Team.all(:league => 'ncaaf')
		teams.each do |team|
			begin
				games = fanfeedr.schedule(:resource => team.resource.to_s)
				games.each do |g|
  				resource_paths = Game.all('$where' => "this.home_team == '#{team.resource.to_s}' || this.away_team == '#{team.resource.to_s}'").collect(&:resource_text)
          # resource_paths = Game.find(:all).collect(&:resource_text)
					unless resource_paths.include?(g["resource_text"])
						Game.create(:date => g["date"], :time => g["time"], :name => g["name"], :league => "ncaaf", :home_score => g["home"]["score"],
												:home_team => g["home"]["team"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], :away_team => g["away"]["team"], 
												:away_winlose => g["away"]["winlose"], :status => g["status"], :resource_text => g["resource_text"], :game_datetime => g["date"].to_s+" "+g["time"].to_s)
					end
				end
				sleep 2
				
			rescue Exception => e
				puts 'RESCUED!'
			end
		end
	end
		
	def self.create_ncaab_games
	  teams = Team.all(:league => 'ncaab')
		teams.each do |team|
      begin
				games = fanfeedr.schedule(:resource => team.resource.to_s)
				unless games.empty?
  				games.each do |g|
    				resource_paths = Game.all('$where' => "this.home_team == '#{team.resource.to_s}' || this.away_team == '#{team.resource.to_s}'").collect(&:resource_text)
            # resource_paths = Game.find(:all).collect(&:resource_text)
  					unless resource_paths.include?(g["resource_text"])
  						Game.create(:date => g["date"], :time => g["time"], :name => g["name"], :league => "ncaab", :home_score => g["home"]["score"],
  												:home_team => g["home"]["team"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], :away_team => g["away"]["team"], 
  												:away_winlose => g["away"]["winlose"], :status => g["status"], :resource_text => g["resource_text"], :game_datetime => g["date"].to_s+" "+g["time"].to_s)
  					end
  				end
			  end
				sleep 2

      rescue Exception => e
        puts 'RESCUED!'
      end
		end
	end
	
	def self.create_games(league)
	  teams = Team.all(:league => league)
		teams.each do |team|
      begin
				games = fanfeedr.schedule(:resource => team.resource.to_s)
				games.each do |g|
  				resource_paths = Game.all('$where' => "this.home_team == '#{team.resource.to_s}' || this.away_team == '#{team.resource.to_s}'").collect(&:resource_text)
          # resource_paths = Game.find(:all).collect(&:resource_text)
					unless resource_paths.include?(g["resource_text"])
						Game.create(:date => g["date"], :time => g["time"], :name => g["name"], :league => league, :home_score => g["home"]["score"], 
												:home_team => g["home"]["team"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], :away_team => g["away"]["team"], 
												:away_winlose => g["away"]["winlose"], :status => g["status"], :resource_text => g["resource_text"], :game_datetime => g["date"].to_s+" "+g["time"].to_s)
					end
				end
				sleep 2
				
      rescue Exception => e
        puts 'RESCUED!'
      end
		end
	end
	
	def self.update_games
	  current_games = Game.all('$where' => "this.league != 'nhl' || this.league != 'mlb'", :status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now })
	  
		unless current_games.empty?
    current_games.each do |game|
        begin
        	schedules = fanfeedr.schedule(:resource => game.away_team.to_s)
        	schedules.each do |g|
      	    if game.resource_text == g["resource_text"]
      	      if game.home_score.nil? || game.home_score <= g["home"]["score"].to_i
    			      game.update_attributes(:time => g["time"], :game_datetime => g["date"].to_s+" "+g["time"].to_s, :home_score => g["home"]["score"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], 
    									              :away_winlose => g["away"]["winlose"], :status => g["status"])
              end
    			  end
      		end
      	  sleep 2
  	  
    		rescue Exception => e
    			puts 'RESCUED!'
    		end
  		end
  	end
	end
	
	def self.update_slow_games
	  current_games = Game.all('$where' => "this.league == 'nhl' || this.league == 'mlb'", :status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now })
	
		unless current_games.empty?
    current_games.each do |game|
        begin
        	schedules = fanfeedr.schedule(:resource => game.away_team.to_s)
        	schedules.each do |g|
      	    if game.resource_text == g["resource_text"]
      	      if game.home_score.nil? || game.home_score <= g["home"]["score"].to_i
    			      game.update_attributes(:time => g["time"], :game_datetime => g["date"].to_s+" "+g["time"].to_s, :home_score => g["home"]["score"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], 
    									              :away_winlose => g["away"]["winlose"], :status => g["status"])
              end
    			  end
      		end
      	  sleep 2
  	  
    		rescue Exception => e
    			puts 'RESCUED!'
    		end
  		end
  	end
	end
	
	def self.create_games_by_team(resource_path)
    # begin
			games = fanfeedr.schedule(:resource => resource_path)
			games.each do |g|
				resource_paths = Game.all('$where' => "this.home_team == '#{resource_path}' || this.away_team == '#{resource_path}'").collect(&:resource_text)
        # resource_paths = Game.find(:all, :conditions => ["home_team = ? || away_team = ?", resource_path, resource_path]).collect(&:resource_text)
				unless resource_paths.include?(g["resource_text"])
					Game.create(:date => g["date"], :time => g["time"], :name => g["name"], :league => Team.first(:resource => g["home"]["team"]).league, :home_score => g["home"]["score"], 
											:home_team => g["home"]["team"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], :away_team => g["away"]["team"], 
											:away_winlose => g["away"]["winlose"], :status => g["status"], :resource_text => g["resource_text"], :game_datetime => g["date"].to_s+" "+g["time"].to_s)
				end
			end
			sleep 2
			
    # rescue Exception => e
    #   puts 'RESCUED!'
    # end
	end
	
	def self.update_games_hourly	  
	  current_games = Game.all('$where' => "this.league != 'nhl' || this.league != 'mlb'", :status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now })

    unless current_games.empty?
  		current_games.each do |game|
        begin
        	schedules = hourly_schedule_resource(game.away_team.to_s)
        	schedules.each do |g|
      	    if game.resource_text == g["resource_text"]
      	      if game.home_score.nil? || game.home_score <= g["home"]["score"].to_i
    			      game.update_attributes(:time => g["time"], :game_datetime => g["date"].to_s+" "+g["time"].to_s, :home_score => g["home"]["score"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], 
    									              :away_winlose => g["away"]["winlose"], :status => g["status"])
    					end
    			  end
      		end
      	  sleep 2
  	  
        rescue Exception => e
          puts 'RESCUED!'
        end
  		end
  	end
	end
	
	def self.update_slow_games_hourly	  
	  current_games = Game.all('$where' => "this.league == 'nhl' || this.league == 'mlb'", :status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now })
	
    unless current_games.empty?
  		current_games.each do |game|
        begin
        	schedules = hourly_schedule_resource(game.away_team.to_s)
        	schedules.each do |g|
      	    if game.resource_text == g["resource_text"]
      	      if game.home_score.nil? || game.home_score <= g["home"]["score"].to_i
    			      game.update_attributes(:time => g["time"], :game_datetime => g["date"].to_s+" "+g["time"].to_s, :home_score => g["home"]["score"], :home_winlose => g["home"]["winlose"], :away_score => g["away"]["score"], 
    									              :away_winlose => g["away"]["winlose"], :status => g["status"])
    					end
    			  end
      		end
      	  sleep 2
  	  
        rescue Exception => e
          puts 'RESCUED!'
        end
  		end
  	end
	end
	
	def self.update_scores_hourly	  
	  current_games = Game.all('$where' => "this.league != 'nhl' || this.league != 'mlb'", :status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now })
	
    unless current_games.empty?
  		current_games.each do |game|
        begin
        	score = hourly_scores_resource(game.away_team.to_s)
    	    if game.date == Date.parse(score["date"])
    	      if game.home_score.nil? || game.home_score <= score["int"][0].to_i
  			      game.update_attributes(:home_score => score["int"][0], :away_score => score["int"][1])
  			    end
  			  end
      	  sleep 2
  	  
        rescue Exception => e
          puts 'RESCUED!'
        end
  		end
  	end
	end
	
	def self.update_slow_scores_hourly	  
	  current_games = Game.all('$where' => "this.league == 'nhl' || this.league == 'mlb'", :status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now })
	
    unless current_games.empty?
  		current_games.each do |game|
        begin
        	score = hourly_scores_resource(game.away_team.to_s)
    	    if game.date == Date.parse(score["date"])
    	      if game.home_score.nil? || game.home_score <= score["int"][0].to_i
  			      game.update_attributes(:home_score => score["int"][0], :away_score => score["int"][1])
  			    end
  			  end
      	  sleep 2
  	  
        rescue Exception => e
          puts 'RESCUED!'
        end
  		end
  	end
	end
	
	def self.update_openfooty
	  current_games = Game.all(:league => "soccer", :game_datetime => { '$gt' => Time.zone.now-3.hours, '$lt' => Time.zone.now })
	  
	  unless current_games.empty?
  		current_games.each do |game|
        begin
        	score = openfooty.match("getStats", :match_id => game.openfooty_match_id).openfooty.match
    	      if game.home_score.nil? || game.home_score <= score.home_team.goals["count"].to_i
  			      game.update_attributes(:home_score => score.home_team.goals["count"], :away_score => score.away_team.goals["count"])
  			    end
  			    
      	  sleep 2
  	  
        rescue Exception => e
          puts 'RESCUED!'
        end
  		end
  	end
	end
	
	def self.create_openfooty_games_by_league(league_id)
			games = openfooty.league("getFixtures", :league_id => league_id).openfooty.fixtures.match
			games.each do |game|
		  begin
  			matchids = Game.all(:openfooty_league_id => 72).collect(&:openfooty_match_id)
  			unless matchids.include?(game.match_id.to_i)
          new_game = Game.new(:date => game.date, :time => game.date, :name => game.away_team+" @ "+game.home_team, :league => "soccer", 
                      :home_team => game.home_team, :away_team => game.away_team, :status => game.status, :game_datetime => game.date, 
                      :openfooty_match_id => game.match_id, :openfooty_league_id => 72, :openfooty_league => game.league, 
                      :openfooty_status => game.status, :openfooty_home_team_id => Team.first(:openfooty_team => game.home_team).openfooty_team_id, 
                      :openfooty_away_team_id => Team.first(:openfooty_team => game.away_team).openfooty_team_id)
          new_game.time = new_game.time-4.hours
          new_game.game_datetime = new_game.game_datetime-4.hours
          new_game.save
  			end
  		rescue Exception => e
        puts 'RESCUED!'
      end
		end
		sleep 2
	end
	
	def self.fanfeedr
	  Fanfeedr::Client.new
	end
	
	def self.hourly_schedule_resource(resource_path)
  	@fanfeedr_application_id = "zpeyk4taevn7rc9en7j34zc4"
		response = HTTParty.get("http://api.fanfeedr.com/basic/schedule?resource=#{resource_path}&appid=#{@fanfeedr_application_id}", :format => :json)
	end
	
	def self.hourly_scores_resource(resource_path)
	  @fanfeedr_application_id = "zpeyk4taevn7rc9en7j34zc4"
  	response = HTTParty.get("http://api.fanfeedr.com/basic/scores?resource=#{resource_path}&appid=#{@fanfeedr_application_id}&rows=1", :format => :xml)["response"]["result"]["doc"]
	end	
	
	def self.openfooty
	  @openfooty = Openfooty::Client.new
	end
end

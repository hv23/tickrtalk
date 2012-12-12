class UpdateOpenfooty
  
  def perform
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
  	
  	Delayed::Job.enqueue(UpdateOpenfooty.new, 0, 10.minutes.from_now)
  end

	def openfooty
	  @openfooty = Openfooty::Client.new
	end

end
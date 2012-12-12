class UpdateSlowGameHourly
  
  def perform
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
  	
  	Delayed::Job.enqueue(UpdateSlowGameHourly.new, 0, 20.minutes.from_now)
  end

	def fanfeedr
	  Fanfeedr::Client.new
	end
	
	def hourly_schedule_resource(resource_path)
  	@fanfeedr_application_id = "zpeyk4taevn7rc9en7j34zc4"
		response = HTTParty.get("http://api.fanfeedr.com/basic/schedule?resource=#{resource_path}&appid=#{@fanfeedr_application_id}", :format => :json)
	end

end
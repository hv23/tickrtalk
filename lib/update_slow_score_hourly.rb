class UpdateSlowScoreHourly
  
  def perform
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
  	
  	Delayed::Job.enqueue(UpdateSlowGameHourly.new, 0, 20.minutes.from_now)
  end

	def fanfeedr
	  Fanfeedr::Client.new
	end
	
	def hourly_scores_resource(resource_path)
	  @fanfeedr_application_id = "zpeyk4taevn7rc9en7j34zc4"
  	response = HTTParty.get("http://api.fanfeedr.com/basic/scores?resource=#{resource_path}&appid=#{@fanfeedr_application_id}&rows=1", :format => :xml)["response"]["result"]["doc"]
	end

end
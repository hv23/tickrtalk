# Long running task to get Twitter updates	
class TwitterUpdate
  
  def perform
  
    current_games = Game.all(:status.ne => /FINAL/i, :game_datetime => { '$gt' => Time.zone.now-5.hours, '$lt' => Time.zone.now+1.hour }, :order => "game_datetime")
    # current_twitter_updates = Update.all(:date_created.gte => 12.hours.ago).collect(&:twitter_id)

    current_games.each do |game|
      if game.league == 'ncaaf' || game.league == 'ncaab'
        home_team = Team.first(:resource => game.home_team).team.gsub('St', 'State')
        away_team = Team.first(:resource => game.away_team).team.gsub('St', 'State')
        sport = game.league
      elsif game.league == 'soccer'
        home_team = game.home_team
        away_team = game.away_team
        sport = game.league
      else
        home_team = Team.first(:resource => game.home_team).mascot
        away_team = Team.first(:resource => game.away_team).mascot
        sport = game.league
      end
      
      if game.league == "mlb"
        sport = "baseball"
      end
  
      game_date = game.date.strftime('%Y-%m-%d')
      (sport == "soccer") ? @game_name = game.away_team+" @ "+game.home_team : @game_name = game.name
  
      # configure list logic
      list = twitter_list(sport)
      last_index = list.index(list.last)
      factor = last_index/25 #Twitter search allows around 49 OR operators
      @limit = 0
  
      game_tweets = []
  
      #get tweets depending on twitter list size
      factor.times do
        begin
          
          if game.keywords.compact.empty?
            game_tweets << Twitter::Search.new([home_team, away_team].join(' OR ')).from(list[@limit..@limit+=25].join(" OR ")).since_date(game_date).since(nil).per_page(20).fetch.results
          else
            game_tweets << Twitter::Search.new([home_team, away_team, game.keywords].join(' OR ')).from(list[@limit..@limit+=25].join(" OR ")).since_date(game_date).since(nil).per_page(20).fetch.results
          end
          
          @limit += 1
        rescue Exception => e
          puts 'RESCUED!'
        end
      end  
  
      # get tweets with remaining listed users
      begin
  
        if game.keywords.compact.empty?
          game_tweets << Twitter::Search.new([home_team, away_team].join(' OR ')).from(list[@limit..last_index].join(" OR ")).since_date(game_date).since(nil).per_page(20).fetch.results
        else
          game_tweets << Twitter::Search.new([home_team, away_team, game.keywords].join(' OR ')).from(list[@limit..last_index].join(" OR ")).since_date(game_date).since(nil).per_page(20).fetch.results
        end
  
      rescue Exception => e
        puts 'RESCUED!'
      end
  	        
      game_tweets.flatten!
      game_tweets.each do |tweet|
        twitter_updates = Update.all(:game_id => game.id, :source => 1, :order => "id desc").collect(&:twitter_id)
      
        if !twitter_updates.include?(tweet.id) && list.include?(tweet.from_user.downcase)
          linkto = "http://twitter.com/#{tweet.from_user}/statuses/#{tweet.id}"
          update = Update.create({:game_id => game.id, :sport_id => Sport.first(:short => game.league).id, :source => 1, :sourcename => 'Twitter',
                                 :content => tweet.text, :twitter_username => tweet.from_user, :linkto => linkto, 
                                 :image_url => tweet.profile_image_url, :epochdate_created => Time.now.to_i, :date_created => Time.now, :twitter_id => tweet.id})
          Orbited.send_data("game_#{game.id}", "#{(render_anywhere('/update/add_gameroom_twitter', {:update_id => update.id, :game_id => game.id, :game_name => @game_name, :user => tweet.from_user, :content => tweet.text, :linkto => linkto, :image_url => tweet.profile_image_url, :date_created => Time.now})).to_s}")
          Orbited.send_data('public_timeline', "#{(render_anywhere('/update/add_twitter', {:game_id => game.id, :game_name => @game_name, :user => tweet.from_user, :content => tweet.text, :linkto => linkto, :date_created => Time.now})).to_s}")
  	      sleep 3
        end
  	  end
    end	
    
    Delayed::Job.enqueue(TwitterUpdate.new, 0, 3.minutes.from_now)
  end
  
  def twitter_list(sport)
    TwitterList.all(:sport => sport).collect{|u|u.user.downcase}
  end
  
  def render_anywhere(partial, assigns)
    view = ActionView::Base.new(Rails::Configuration.new.view_path, assigns)
    # ActionView::Base.helper_modules.each { |helper| view.extend helper }
    # view.extend ApplicationHelper
    view.render(:partial => partial)
  end 
end
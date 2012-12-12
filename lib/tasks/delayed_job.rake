desc "Delayed job"
task :delayed_job => :environment do
  Delayed::Job.delete_all
  
  Delayed::Job.enqueue(TwitterUpdate.new)
  
  ## Uncomment when football/basketball season start
  # Delayed::Job.enqueue(UpdateGame.new, 0, 3.minutes.from_now)
  # Delayed::Job.enqueue(UpdateGameHourly.new, 0, 5.minutes.from_now)
  
  Delayed::Job.enqueue(UpdateSlowGame.new, 0, 1.minute.from_now)
  Delayed::Job.enqueue(UpdateSlowGameHourly.new, 0, 10.minutes.from_now)
  Delayed::Job.enqueue(UpdateOpenfooty.new)
end
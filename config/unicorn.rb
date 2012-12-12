# unicorn_rails -c /web/tickrtalk/config/unicorn.rb -E production -D

rails_env = ENV['RAILS_ENV'] || 'production'

# 2 workers and 1 master
worker_processes (rails_env == 'production' ? 2 : 1)

# Load into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
listen '/web/tickrtalk/tmp/sockets/unicorn.sock', :backlog => 64

pid "/web/tickrtalk/tmp/pids/unicorn.pid"

stderr_path "/web/tickrtalk/log/unicorn.stderr.log"
stdout_path "/web/tickrtalk/log/unicorn.stdout.log"

##
# REE

# http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a database connection
  MongoMapper.database.connection.close 
  
  old_pid = '/tmp/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    # someone else did our job for us
    end
  end

end

after_fork do |server, worker|

  # Start Mongo
  begin
    include MongoMapper
    db_config = YAML::load(File.read(File.join(Rails.root, "/config/mongodb.yml")))

    if db_config[Rails.env] && db_config[Rails.env]['adapter'] == 'mongodb'
      mongo = db_config[Rails.env]
      MongoMapper.connection = Mongo::Connection.new(mongo['host'] || 'localhost',
                                                     mongo['port'] || 27017,
                                                    :logger => Rails.logger)
      MongoMapper.database = mongo['database']

      if mongo['username'] && mongo['password']
        MongoMapper.database.authenticate(mongo['username'], mongo['password'])
      end
    end
  rescue
    RAILS_DEFAULT_LOGGER.error("Couldn't connect to Mongo Server")
  end

end
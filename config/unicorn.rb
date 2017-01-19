# config/unicorn.rb
num_processes = Integer(ENV["WEB_CONCURRENCY"] || 2)
puts "Using #{num_processes} Unicorn processes"
worker_processes num_processes
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  #defined?(Infrastructure::Cache) and Infrastructure::Cache.disconnect
  defined?(Infrastructure::DocStore) and Infrastructure::DocStore.disconnect
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  #defined?(Infrastructure::Cache) and Infrastructure::Cache.boot_up
  defined?(Infrastructure::DocStore) and Infrastructure::DocStore.boot_up
end
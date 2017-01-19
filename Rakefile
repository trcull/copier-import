#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
begin
  File.open(".env").each_line do |line|  
    tokens = line.split("=")
    if tokens.length > 0 && !tokens[1].nil? && !tokens[0].nil?
      ENV[tokens[0].strip] ||= tokens[1].strip.chomp
    end
  end
rescue => e
  puts "could not find the .env file"
end

require File.expand_path('../config/application', __FILE__)

RetentionfactoryEngine::Application.load_tasks

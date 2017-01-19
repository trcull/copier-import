namespace :maintenance do
    task :nightly => :environment do |t, args|
      puts "doing nightly maintenance task"
      Batch::Nightly.new.delay.perform
    end

    task :hourly => :environment do |t, args|
      puts "doing hourly maintenance task"
      Batch::Hourly.new.delay.perform
    end

end

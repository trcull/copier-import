

# Added this check so that the following RSpec Rake tasks are not loaded
# for staging or production...since RSpec is grouped in development and test only.
if Rails.env.development? || Rails.env.test?
  desc "Run the code examples only marked functional - meaning they visit pages, click links, and do end-to-end, user-focused tests that cut across components"

  RSpec::Core::RakeTask.new("spec:functional") do |t|
    t.name = "spec:functional"
    t.pattern = "./spec/**/*_spec.rb"  #there doesn't appear to be a way to exclude tests from the default :spec task unless you monkey with the file names.
    t.rspec_opts = "--tag functional --tag ~integration --profile" 
  end
  RSpec::Core::RakeTask.new("spec:integration") do |t|
    t.name = "spec:integration"
    t.pattern = "./spec/**/*_spec.rb"  #there doesn't appear to be a way to exclude tests from the default :spec task unless you monkey with the file names.
    t.rspec_opts = "--tag ~oauth --tag ~functional --tag integration --profile" 
  end

end


source 'https://rubygems.org'

ruby "2.1.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '~> 4.0.0'
gem 'rails', '~> 4.1.0'
gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'unicorn'
gem 'parallel'
gem 'delayed_job_active_record'
gem 'oauth'

gem 'lograge'
gem 'attr_encrypted'
gem 'nokogiri'

#used for generating onetime login tokens
gem 'rotp' 

#ruby-freshbooks-0.4 overrides a private method in httparty, so we need at least 0.4.1, which doesn't override that method'
gem 'ruby-freshbooks', '>= 0.4.1'

gem 'rest-client'

gem 'aws-sdk'

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'factory_girl_rails', '~> 4.4.0'
  gem 'forgery'
end

gem "active_model_serializers"
#compliments http://welldonethings.com/tags/manager/v3
gem "tagmanager-rails", "~> 3.0.0.1"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'execjs'
gem 'therubyracer'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# see: http://blog.steveklabnik.com/posts/2013-06-25-removing-turbolinks-from-rails-4
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

#required by Heroku
#group :production, :staging do
#  gem 'rails_12factor'
#end

gem 'devise'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

#see: https://github.com/Empact/roo.  there are other repos, but don't be fooled!
gem 'roo'

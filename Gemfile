source 'https://rubygems.org'

ruby '2.1.1'

gem 'rails', '3.2.17'

# data
gem 'pg'
gem 'squeel'

# local ENV
gem 'figaro'

# workers
gem 'sidekiq'
gem 'sinatra', require: false

# authentication
gem 'devise', '~> 2.2'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'twitter'
gem 'fb_graph'
gem 'bcrypt-ruby'

# other libraries
gem 'virtus'
gem 'active_model_serializers'
gem 'paper_trail'
gem 'friendly_id', '~> 4.0.9'
gem 'kaminari'
gem 'public_activity'
gem 'rest-client'
gem 'fastimage'
gem 'unread'
gem 'simple_enum'
gem 'open_uri_redirections' # allows open-uri redirects from http->https

# templates & helpers
gem 'haml-rails'
gem 'simple_form'

# assets that must be outside of 'assets' group to work on heroku
gem 'ember-rails', github: 'emberjs/ember-rails'
gem 'ember-source', '>= 1.0.0.beta.3'
gem 'ember-data-source', '>= 1.0.0.beta.7'
gem 'filepicker-rails'

# monitoring / error reporting
gem 'newrelic_rpm'
gem 'sentry-raven'
gem 'skylight'

# used in rake tasks
gem 'populator'
gem 'ffaker'
gem 'forgery'

# solr search
gem 'sunspot_rails'
gem 'progress_bar'


group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  gem 'uglifier'

  gem 'bourbon'
  gem 'bootstrap-sass'

  gem 'jquery-rails'
  gem 'momentjs-rails'

  gem 'ember_simple_auth-rails'

  gem 'turbo-sprockets-rails3'
end

group :development do
  gem 'foreman'

  gem 'letter_opener'
  gem 'annotate'

  gem 'pry'
  gem 'awesome_print'
  gem 'pry-rails'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'

  gem 'capistrano', '< 3.0.0'
  gem 'capistrano-ext'
  gem 'capistrano-local-precompile', require: false

  gem 'nifty-generators'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.14.0'    # for tests
  gem 'spork'                       # speedier tests
  gem 'guard-rspec'                 # watch app files
  gem 'guard-spork'                 # spork integration
  gem 'database_cleaner'            # cleanup database in tests
  gem 'fabrication'                 # model stubber
  gem 'shoulda'                     # model spec tester
  gem 'rb-inotify', require: false  # Linux file notification
  gem 'rb-fsevent', require: false  # OSX file notification
  gem 'rb-fchange', require: false  # Windows file notification
  gem 'jasminerice', github: 'bradphelan/jasminerice'
  gem 'sunspot_solr'
end

group :production, :staging, :local do
  gem 'unicorn'
end

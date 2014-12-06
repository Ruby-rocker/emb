set :user, 'yostalgia'
set :sudo_user, 'deploy'
server 'localhost', :web, :app, :db, :redis, :primary => true
set :port, 2222

set :deploy_to, '/home/yostalgia/apps/yostalgia'
set :rails_env, 'local'

set :branch, 'develop'

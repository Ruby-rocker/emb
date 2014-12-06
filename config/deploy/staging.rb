set :user, 'yostalgia'
set :sudo_user, 'deploy'
server 'direct.staging.yostalgia.com', :web, :app, :db, :redis, :primary => true

set :deploy_to, '/home/yostalgia/apps/yostalgia'
set :rails_env, 'staging'

set :branch, 'develop'

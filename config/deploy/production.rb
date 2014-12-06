set :user, 'yostalgia'
set :sudo_user, 'deploy'
server 'direct.yostalgia.com', :web, :app, :db, :redis, :primary => true

set :deploy_to, '/home/yostalgia/apps/yostalgia'
set :rails_env, 'production'

set :branch, 'master'

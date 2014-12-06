require 'bundler/capistrano'
require 'capistrano/ext/multistage'
# require 'sidekiq/capistrano'
require 'new_relic/recipes'
require 'capistrano/local_precompile'

load 'config/cap_tasks/base'
load 'config/cap_tasks/nginx'
load 'config/cap_tasks/unicorn'
load 'config/cap_tasks/sidekiq'
load 'config/cap_tasks/monit'

set :default_environment, {
  'PATH' => '/opt/rbenv/shims:/opt/rbenv/bin:$PATH',
  'RBENV_ROOT' => '/opt/rbenv'
}

set :application, 'yostalgia'

set :scm, :git
set :repository,  'git@bitbucket.org:simpleasmilk/yostalgia.git'
set :branch, 'master'
set :deploy_via, :remote_cache

set :bundle_flags, '--deployment --quiet --binstubs --shebang ruby-local-exec'

set :turbosprockets_enabled, true

set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :target_os, :ubuntu

namespace :custom do
  desc 'Shared storage folders and symlinks to the release'
  task :file_system, roles: :app do
    run_locally %Q(rails runner 'output = File.open("_application_.yml", "w"); output << Figaro.env("#{stage}").to_yaml; output.close')
    transfer :up, '_application_.yml', "#{shared_path}/application.yml", via: :scp
    run_locally 'rm _application_.yml'

    run "ln -nfs #{shared_path}/database.yml #{release_path}/config"
    run "ln -nfs #{shared_path}/application.yml #{release_path}/config"

    # copy solr config over
    with_sudo_user do
      sudo "cp -f #{release_path}/solr/conf/schema.xml /usr/share/solr/conf/schema.xml"
      sudo "chown -R jetty:jetty /usr/share/solr/conf/schema.xml"
      sudo "service jetty restart"
    end
  end

  desc 'Create the .rbenv-version file'
  task :rbenv_version, roles: :app do
    run "cd #{release_path} && rbenv local 2.1.1"
  end
end

namespace :solr do
  task :reindex, roles: :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex"
  end
end

before 'bundle:install', 'custom:rbenv_version'
before 'deploy:assets:precompile', 'custom:file_system'
after 'deploy:restart', 'deploy:cleanup'

# We need to run this after our collector mongrels are up and running
# This goes out even if the deploy fails, sadly
after "deploy", "newrelic:notice_deployment"
after "deploy:update", "newrelic:notice_deployment"
after "deploy:migrations", "newrelic:notice_deployment"
after "deploy:cold", "newrelic:notice_deployment"

namespace :sidekiq do
  desc 'Generate and upload Upstard configs for daemons needed by the app'
  task :setup, roles: :app do
    template "sidekiq_upstart.erb", "/tmp/sidekiq.conf"
    with_sudo_user do
      sudo "mv /tmp/sidekiq.conf /etc/init/sidekiq.conf"
    end
  end
  after 'deploy:setup', 'sidekiq:setup'


  desc 'Start the sidekiq workers via Upstart'
  task :start do
    with_sudo_user do
      sudo 'start sidekiq'
    end
  end

  desc 'Stop the sidekiq workers via Upstart'
  task :stop do
    with_sudo_user do
      sudo 'stop sidekiq || true'
    end
  end

  desc 'Restart the sidekiq workers via Upstart'
  task :restart do
    with_sudo_user do
      sudo 'stop sidekiq || true'
      sudo 'start sidekiq'
    end
  end

  desc "Quiet sidekiq (stop accepting new work)"
  task :quiet do
    pid_file       = "#{current_path}/tmp/pids/sidekiq.pid"
    sidekiqctl_cmd = "bundle exec sidekiqctl"
    run "if [ -d #{current_path} ] && [ -f #{pid_file} ] && kill -0 `cat #{pid_file}`> /dev/null 2>&1; then cd #{current_path} && #{sidekiqctl_cmd} quiet #{pid_file} ; else echo 'Sidekiq is not running'; fi"
  end
end

before 'deploy:update_code', 'sidekiq:quiet'
after  'deploy:stop',        'sidekiq:stop'
after  'deploy:start',       'sidekiq:start'
before 'deploy:restart',     'sidekiq:restart'

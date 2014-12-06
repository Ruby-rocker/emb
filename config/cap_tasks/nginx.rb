namespace :nginx do
  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx_unicorn.erb", "/tmp/nginx_conf"

    if rails_env == 'staging'
      template "staging_htpasswd", "/tmp/staging_htpasswd"
      with_sudo_user do
        sudo "mv /tmp/staging_htpasswd #{shared_path}/staging_htpasswd"
        sudo "chmod a+r #{shared_path}/staging_htpasswd"
      end
    end

    with_sudo_user do
      sudo "mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
      sudo "rm -f /etc/nginx/sites-enabled/default"
      sudo "rm -f /etc/nginx/sites-enabled/000-default"
    end
    restart
  end
  after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      with_sudo_user do
        sudo "service nginx #{command}"
      end
    end
  end
end

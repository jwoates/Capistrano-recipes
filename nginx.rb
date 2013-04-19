namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install, roles: :web do
    run "#{sudo} add-apt-repository -y ppa:nginx/stable"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install nginx"
    run "#{sudo} update-rc.d nginx defaults"
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    template "nginx/nginx_unicorn.erb", "/tmp/nginx_conf"

    if basic_authentication === true
        puts "*******************************************************"
        puts "* Create a password for basic http authentication     *"
        puts "*******************************************************"
        set(:pw, Capistrano::CLI.password_prompt("Set Basic Auth Password: ") )
        set(:http_password, pw.crypt(%Q{salt}) )
        sudo_template "nginx/htpasswd.erb", "/home/#{system_user}/htpasswd-alt"
    end 


    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    restart
  end
  after "deploy:setup", "nginx:setup"
  
  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
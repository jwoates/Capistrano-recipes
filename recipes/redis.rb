namespace :redis do
  desc "Install the latest relase of Node.js"
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install redis-server"
    restart
  end
  after "deploy:install", "redis:install"

  %w[start stop restart].each do |command|
    desc "#{command} redis server"
    task command, roles: :web do
      run "#{sudo} /etc/init.d/redis-server #{command}"
    end
  end
end
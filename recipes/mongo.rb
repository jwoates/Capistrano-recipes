namespace :mongodb do    
  desc "Installs mongodb binaries and all dependencies"
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
    run "#{sudo} touch /etc/apt/sources.list.d/10gen.list"
    run "#{sudo} sh -c \"echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' >> /etc/apt/sources.list.d/10gen.list\""
    run "#{sudo} sudo apt-get -y update"
    run "#{sudo} apt-get -y install mongodb-10gen"
    restart
  end
  after "deploy:install", "mongodb:install"

  %w[start stop restart].each do |command|
    desc "#{command} mongodb"
    task command, roles: :web do
      run "#{sudo} service mongodb #{command}"
    end
  end
end

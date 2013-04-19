set_default(:mysql_host) { "localhost" }
set_default(:mysql_user) { application }
set_default(:mysql_password) { Capistrano::CLI.password_prompt "MySQL Password: " }
set_default(:mysql_database) { application }
set_default(:mysql_pid) { "/var/run/mysqld/mysqld.pid" }

namespace :mysql do
  desc "Install the latest stable release of MySQL."
  task :install, roles: :db, only: {primary: true} do
    run "echo mysql-server-5.1 mysql-server/root_password password #{mysql_password} | #{sudo} debconf-set-selections"
    run "echo mysql-server-5.1 mysql-server/root_password_again password #{mysql_password} | #{sudo} debconf-set-selections"
    run "#{sudo} apt-get -y install mysql-server libmysql-ruby libmysqlclient-dev"
  end
  after "deploy:install", "mysql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    cmd = "CREATE DATABASE IF NOT EXISTS #{mysql_database}; GRANT ALL PRIVILEGES ON #{mysql_database}.* TO #{mysql_user}@localhost IDENTIFIED BY '#{mysql_password}';"
    run "mysql -u root -p -e \"#{cmd}\"" do |channel, stream, data|
      if data =~ /^Enter password:/
        channel.send_data "#{mysql_password}\n"
      end
    end
  end
  after "deploy:setup", "mysql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mysql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "mysql:symlink"

  %w[start stop restart].each do |command|
    desc "#{command} MySQL server"
    task command, roles: :web do
      run "#{sudo} /etc/init.d/mysql #{command}"
    end
  end
end

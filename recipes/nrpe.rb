def sudo_template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), "/tmp/temp_file"
  run "#{sudo} mv -f /tmp/temp_file #{to}"
end

namespace :nrpe do
  
  desc "Install NPRE for remote server monitoring"
  
  # Install NRPE

  task :auth do
    if basic_authentication === true
        puts "*******************************************************"
        puts "* Create a password for basic http authentication     *"
        puts "*******************************************************"
        set(:pw, Capistrano::CLI.password_prompt("Set Basic Auth Password: ") )
        set(:http_password, pw.crypt(%Q{salt}) )
        sudo_template "nginx/htpasswd.erb", "/home/#{system_user}/htpasswd-alt"
    end 
  end 

  task :setuser do
    puts "create Nagios User and Password"
    set(:pw, Capistrano::CLI.password_prompt("Create Password: ") )
    set(:nagios_password, pw.crypt(%Q{salt}) )

    run "#{sudo} /usr/sbin/useradd nagios -p #{nagios_password}"
  end 

  task :install do

    #ready the system
    #run "#{sudo} apt-get update && #{sudo} apt-get -y upgrade"
    #run "#{sudo} apt-get install build-essential"

    # create nagios user with password prompt, use normal RH password
    puts "*************************************"
    puts "* create Nagios User and Password   *"
    puts "*************************************"

    set(:pw, Capistrano::CLI.password_prompt("Create Nagios User Password: ") )
    set(:nagios_password, pw.crypt(%Q{salt}) )

    run "#{sudo} /usr/sbin/useradd nagios -p #{nagios_password}"

    # LibSSL
    run "#{sudo} apt-get -y install libssl-dev"

    #add alias
    run "#{sudo} ln -s -f /lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/libssl.so"

    # download and configure plugins
    run "#{sudo} mkdir -p /home/roundhouse/downloads"
    run "#{sudo} wget -P /home/roundhouse/downloads/ http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.16.tar.gz"
    run "#{sudo} tar -zxf /home/roundhouse/downloads/nagios-plugins-1.4.16.tar.gz -C /home/roundhouse/downloads/"
    #run "cd nagios-plugins-1.4.16"
    run "cd /home/roundhouse/downloads/nagios-plugins-1.4.16/ && #{sudo} ./configure"
    run "cd /home/roundhouse/downloads/nagios-plugins-1.4.16/ && #{sudo} make"
    run "cd /home/roundhouse/downloads/nagios-plugins-1.4.16/ && #{sudo} make install"


    #add check_nagios plugin (shell script)
    sudo_template "nrpe/check_nginx.sh.erb", "/usr/local/nagios/libexec/check_nginx.sh"
    run "#{sudo} chmod 0755 /usr/local/nagios/libexec/check_nginx.sh"

    run "#{sudo} chown nagios.nagios /usr/local/nagios"
    run "#{sudo} chown -R nagios.nagios /usr/local/nagios/libexec"

    # install Xinted
    run "#{sudo} apt-get -y install xinetd"
    
    # install NRPE plugin
    #run "cd ~/downloads"
    run "#{sudo} wget -P /home/roundhouse/downloads/ http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.14/nrpe-2.14.tar.gz"
    run "#{sudo} tar -zxf /home/roundhouse/downloads/nrpe-2.14.tar.gz -C /home/roundhouse/downloads/"
    
    #run "cd nrpe-2.14"
    run "cd /home/roundhouse/downloads/nrpe-2.14/ && #{sudo} ./configure"
    run "cd /home/roundhouse/downloads/nrpe-2.14/ && #{sudo} make"
    run "cd /home/roundhouse/downloads/nrpe-2.14/ && #{sudo} make install-plugin"
    run "cd /home/roundhouse/downloads/nrpe-2.14/ && #{sudo} make install-daemon"
    run "cd /home/roundhouse/downloads/nrpe-2.14/ && #{sudo} make install-daemon-config"
    run "cd /home/roundhouse/downloads/nrpe-2.14/ && #{sudo} make install-xinetd"

    #create nrpe configs
    sudo_template "nrpe/nrpe.cfg.erb", "/usr/local/nagios/etc/nrpe.cfg"
    sudo_template "nrpe/nrpe_local.cfg.erb", "/usr/local/nagios/etc/nrpe_local.cfg"
    
    # configure Xinted with nrpe
    sudo_template "nrpe/nrpe.erb", "/etc/xinetd.d/nrpe"

    # restart Xinted
    run "#{sudo} service xinetd restart"

    # update firewall
    # probably not needed, will fail if no FW, but should not be a problem as it's the last command
    # run "#{sudo} iptables -I RH-Firewall-1-INPUT -p tcp -m tcp --dport 5666 -j ACCEPT"

    puts "Nagios NPRE is installed configured, and running, update Nagios server to monitor this machine"

  end
  after "deploy:install", "nrpe:install"


end
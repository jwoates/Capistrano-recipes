def sudo_template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), "/tmp/temp_file"
  run "#{sudo} mv -f /tmp/temp_file #{to}"
end

def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties"
  end

  task :add_keys do
    # run "#{sudo} echo \"export #{key}=#{value}}\" >> greetings.txt"
  end

end

task :tail, :roles => :app do
  trap("INT") { puts 'Interupted'; exit 0; }
  run "cd #{shared_path}/log/; tail -f production.log staging.log nginx.access.log nginx.error.log unicorn.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err
  end
end

namespace :env do
  task :sync do
    transfer :up, "./config/config.yml", "#{shared_path}/config/config.yml", :via => :scp
    # symlink_env
  end
  task :symlink_env do
    run "#{sudo} ln -sf #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
end
## commented out hook because someone might ONLY want to work on their environment but still push to stage
# before 'deploy:finalize_update', 'env:sync'

# namespace :rails do
#   task :console do
#     run "cd #{current_path}; bundle exec rails console #{rails_env}" do |channel, stream, data|
#       next if data.chomp == input.chomp || data.chomp == ''
#       print data
#       channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
#     end
#   end
# end
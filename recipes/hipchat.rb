namespace :hipchat do
  task :create_room do
    require 'uri'
    require 'net/http'
    require 'json'
    uri = URI.parse('http://api.hipchat.com/v1/rooms/create')
    res = Net::HTTP.post_form(uri, 'auth_token' => "#{hipchat_token}", 'name' => "#{hipchat_room_name}", 'owner_user_id' => "183855")
    result = JSON.parse(res.body)
    if !result['error']
      puts "Create hipchat room #{result['room']['name']}"
    else
      puts "Couldn't create a hipchat room #{hipchat_room_name}"
      puts "Error: #{result['error']['message']}"
    end
  end
end
after  "deploy:setup", "hipchat:create_room"
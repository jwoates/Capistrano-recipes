# ip address
set :domain, <ip>

set :rails_env, "staging"

# you should uncomment this and create a stage or development branch
set :branch, "deploy"

set :hipchat_color, 'green' #finished deployment message color

# user the applicationw ill run under
set :system_user, ''
set :http_auth, true
set :http_auth_password, ''
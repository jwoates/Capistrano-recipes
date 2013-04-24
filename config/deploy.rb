# require 'bundler/setup'
# require 'bundler/capistrano'
# require 'hipchat/capistrano'

set :scm, "git"
set :repository, "git@github.com:allibubba/Capistrano-recipes.git"
set :origin, "origin"
set :branch, "deploy"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
role :db,  "your slave db-server here"


# user the application will run under
set :system_user, 'roundhouse'

# add basic http authentication? if true specify password.
set :http_auth, true
set :http_auth_password, ''
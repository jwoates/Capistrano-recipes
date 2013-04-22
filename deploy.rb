require "bundler/setup"

require "bundler/capistrano"
require 'hipchat/capistrano'

system('eval `ssh-agent`')

set :user, "roundhouse"
set :application, "Darwin"
set :repo_name, "darwin"
set(:deploy_to) { "/home/#{user}/apps/#{application}" }
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:roundhouse/#{repo_name}.git"
set :origin, "origin"
set :branch, "deploy"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
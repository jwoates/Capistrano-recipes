namespace :imagemagick do
  desc "Install the latest relase of ImageMagick"
  task :install, roles: :app do
    run "#{sudo} apt-get -y install libmagickwand-dev"
    run "#{sudo} apt-get -y install imagemagick"
    run "#{sudo} apt-get -y install libxslt-dev"
  end
  after "deploy:install", "imagemagick:install"
end
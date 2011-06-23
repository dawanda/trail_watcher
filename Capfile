load "deploy"
require 'bundler/capistrano'

set :application, "Trail Watcher"

set :scm, :git
set :repository, "git://github.com/dawanda/trail_watcher.git"
set :branch, ENV['BRANCH'] || "master"

set :deploy_to, '/srv/trail_watcher'
set :keep_releases, 5

set :user, 'deploy'
ssh_options[:keys] = "~/.ssh/deploy_id_rsa"
set :use_sudo, false

# production or staging ?
task(:production){}
set :stage, (ARGV.first == 'production' ? :production : :staging)

require 'lib/cfg'
CFG = CFGLoader.load[stage]

CFG[:deploy][:servers].each do |ip|
  role :app, ip
  role :web, ip
end

namespace :deploy do
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt" unless ENV['NO_RESTART']
  end

  task :copy_config_files do
    run "cp #{deploy_to}/shared/config/*.yml #{current_release}/config/"
  end
  after 'deploy:update_code', 'deploy:copy_config_files'
end
after "deploy", "deploy:cleanup"

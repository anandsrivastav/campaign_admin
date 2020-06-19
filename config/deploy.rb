# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "campaign"
set :repo_url, "git@github.com:anandsrivastav/campaign_admin.git" 
set :branch, :master
set :stage, :production
set :deploy_to, "/home/deploy/campaign"
set :linked_files, %w{config/database.yml config/master.key}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  task :seed do
   puts "\n=== Seeding Database ===\n"
   on primary :db do
    within current_path do
      execute :rake, 'db:seed'
    end
   end
  end
end


namespace :deploy do
  task :restart_server do
   puts "\n=== Restart Server on port 3000 ===\n"
   on primary :db do
    within current_path do
      execute :rails, 'server -b 0.0.0.0 -p 3000 -e production'
    end
   end
  end
end

#after "deploy:publishing", "deploy:seed"

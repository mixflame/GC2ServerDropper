namespace :dropper do
  task :restart_all => :environment do
    ServerDropper.restart_all_servers
  end
end
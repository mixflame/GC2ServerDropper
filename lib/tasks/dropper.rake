namespace :dropper do
  task :restart_all => :environment do
    ServerDropper.restart_all_servers
  end
end

task :log do
  `ssh -t globalchat@globalchat2.net "tail -fn 500 ~/ServDrop/log/production.log"'`
end
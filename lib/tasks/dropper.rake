namespace :dropper do
  task :restart_all => :environment do
    ServerDropper.restart_all_servers
  end
  # never used
  # task :destroy_all => :environment do
  #   ServerDropper.destroy_all_servers
  # end
end

task :log do
  exec('ssh -t globalchat@globalchat2.net "tail -fn 500 ~/ServDrop/log/production.log"')
end

task :passlog do
  exec('ssh -t globalchat@globalchat2.net "tail -fn 500 ~/ServDrop/log/passenger.80.log"')
end

task :devlog do
  exec('ssh -t globalchat@globalchat2.net "tail -fn 500 ~/ServDrop/log/development.log"')
end
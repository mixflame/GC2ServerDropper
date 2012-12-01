class Server < ActiveRecord::Base
  attr_accessible :buffer_replay,
  :host,
  :name,
  :password,
  :port,
  :private,
  :email,
  :pass

  def start
    logger.info "starting server #{self.host}:#{self.port}"
    # binding.pry
    server_path = "#{Rails.root.to_s}/bin/server.rb '#{self.host}' '#{self.port}' '#{self.name}' '#{self.password}' '#{self.private}' '#{self.buffer_replay}' "
    logger.info "path: #{server_path}"
    io = IO.popen(server_path)
    pid = io.pid
    #`#{server_path}`
    #pid = $?.pid
    logger.info "opened server, pid #{pid}"
    self.update_attribute(:pid, pid)
  end


  def restart
    logger.info "restarting server #{self.host}:#{self.port}"
    self.stop
    self.start
  end

  def stop
    logger.info "stopping server #{self.host}:#{self.port} pid #{self.pid}"
    #result = exec("kill #{self.pid}")
    #logger.info "kill result: #{result}"
    `pkill -TERM -P #{self.pid}`
  end

end
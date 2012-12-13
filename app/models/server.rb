class Server < ActiveRecord::Base
  attr_accessible :buffer_replay,
  :host,
  :name,
  :password,
  :port,
  :private,
  :email,
  :pass

  # they may only have one
  validates_uniqueness_of :email

  def start
    logger.info "starting server #{self.host}:#{self.port}"
    # binding.pry
    server_path = "#{Rails.root.to_s}/bin/server.coffee '#{self.host}' '#{self.port}' '#{self.name}' '#{self.password}' '#{self.private}' '#{self.buffer_replay}'"
    logger.info "path: #{server_path}"
    fork do
      io = IO.popen(server_path) do |f|
        pid = f.gets # says its pid
      end
      logger.info "opened server, pid #{pid}"
      self.update_attribute(:pid, pid)
    end
  end


  def restart
    logger.info "restarting server #{self.host}:#{self.port}"
    self.stop
    self.start
  end

  def stop
    logger.info "stopping server #{self.host}:#{self.port} pid #{self.pid}"
    Process.kill 'INT', self.pid
  end

end
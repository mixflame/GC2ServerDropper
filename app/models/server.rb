class Server < ActiveRecord::Base
  attr_accessible :buffer_replay,
  :host,
  :name,
  :password,
  :port,
  :private

  def start
    logger.info "starting server #{self.host}:#{self.port}"
    # binding.pry
    server_path = "#{File.expand_path(File.dirname(__FILE__))}/../../bin/server.rb '#{self.host}' '#{self.port}' '#{self.name}' '#{self.password}' '#{self.private}' '#{self.buffer_replay}' "
    logger.info "path: #{server_path}"
    io = IO.popen(server_path)
    pid = io.pid
    logger.info "opened server, pid #{pid}"
    self.update_attribute(:pid, pid)
  end


  def restart
    logger.info "restarting server #{@host}:#{@port}"
  end

  def stop
    logger.info "stopping server #{@host}:#{@port}"
    result = exec("kill #{self.pid}")
    logger.info "kill result: #{result}"
  end

end
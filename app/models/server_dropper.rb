class ServerDropper

  def self.create_server host, name, password, is_private, has_scrollback
    port = ServerDropper.find_open_port
    server = Server.new(:host=>host, :port=>port, :name=>name, :password => password, :private=>is_private, :buffer_replay=>has_scrollback)
    server.save
    server.start
    server
  end

  def self.destroy_server id
    server = Server.find(id)
    server.stop
    server.destroy
  end


  def self.restart_server id
    server = Server.find(id)
    server.restart
    server
  end

  def self.find_open_port
    require 'socket'
    socket = Socket.new(:INET, :STREAM, 0)
    socket.setsockopt(:SOCKET, :REUSEADDR, 1)
    socket.bind(Addrinfo.tcp("127.0.0.1", 0))
    port = socket.local_address.ip_port
    socket.close
    port
  end

  def self.restart_all_servers
    servers = Server.all
    servers.each do |server|
      logger.info "restarting #{server.inspect}"
      server.restart
    end
  end

  def self.check_server(host, port)
    gcc = GlobalChatController.new
    gcc.handle = "test user"
    gcc.host = host
    gcc.port = port
    gcc.password = ""
    gcc.nicks = []
    gcc.chat_buffer = ""
    gcc.sign_on
    sleep 3
    val = gcc.chat_token != nil
    gcc.sign_out
    val
  end

end

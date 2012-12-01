require 'global_chat_controller'

class ServerDropper

  def self.create_server host, name, password, is_private, has_scrollback, email, pass
    port = ServerDropper.find_open_port
    server = Server.new(:host=>host, :port=>port, :name=>name, :password => password, :private=>is_private, :buffer_replay=>has_scrollback, :email=>email, :pass=>pass)
    server.save!
    ServerMailer.send_login_deetz(email, pass, host, port).deliver
    server
  end

  def self.destroy_server id
    server = Server.find(id)
    server.stop
    server.destroy
  end

  def self.start_server id
    server = Server.find(id)
    server.start
    server
  end

  def self.restart_server id
    server = Server.find(id)
    server.restart
    server
  end

  def self.find_open_port
    require 'socket'
    socket = Socket.new(:INET, :STREAM, 0)
    socket.setsockopt(:SOCKET, :REUSEADDR, 1) # note the reuseaddr
    socket.bind(Addrinfo.tcp("127.0.0.1", 0))
    port = socket.local_address.ip_port
    socket.close
    port
  end

  # admin method, call after code update
  # from rake task
  def self.restart_all_servers
    servers = Server.all
    servers.each do |server|
      puts "restarting #{server.inspect}"
      server.restart
    end
  end

  # lol
  def self.destroy_all_servers
    servers = Server.all
    servers.each do |server|
      puts "destroying #{server.inspect}"
      ServerDropper.destroy_server server.id
    end
  end

  # nexus security
  # lives here because of cloud rules
  def self.check_server(host, port, password="")
    gcc = GlobalChatController.new
    gcc.handle = "ChatCheckBot"
    gcc.host = host
    gcc.port = port
    gcc.password = password
    gcc.nicks = []
    gcc.chat_buffer = ""
    gcc.sign_on
    sleep 3
    val = gcc.chat_token != nil
    gcc.sign_out
    val
  end

end

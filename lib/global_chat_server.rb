#!/usr/bin/env ruby
require 'gserver'
require 'net/http'
require 'uri'
require 'securerandom'
require 'pstore'

class GlobalChatServer < GServer

  attr_accessor :handles, :buffer, :handle_keys, :sockets, :password, :socket_keys, :scrollback, :server_name

  def initialize(port=9994, *args)
    super(port, *args)
    self.audit = true
    self.debug = true
    @pstore = PStore.new("gchat.pstore")
    @handle_keys = {} # stores handle
    @socket_keys = {} # stores chat_token
    # @port_keys = {} # unnecessary in PING design
    @handle_last_pinged = {} # used for clone removal
    @handles = []
    @sockets = []
    @buffer = []
    @server_name = "GlobalChatNet"
    load_chat_log
    @mutex = Mutex.new
  end

  def broadcast(message, sender=nil)
    @mutex.synchronize do
      @sockets.each do |socket|
        begin
          sock_send(socket, message) unless socket == sender
        rescue
          log "broadcast fail removal event"
          remove_dead_socket socket
        end
      end
    end
  end

  def remove_dead_socket(socket)
    @sockets.delete socket
    ct = @socket_keys[socket]
    handle = @handle_keys[ct]
    @handles.delete handle
    @handle_keys.delete ct
    @socket_keys.delete socket
  end

  def remove_user_by_handle(handle)
    ct = @handle_keys.key(handle)
    handle = @handle_keys[ct]
    socket = @socket_keys.key(ct)
    @sockets.delete socket

    @handles.delete handle
    @handle_keys.delete ct
    @socket_keys.delete socket
    begin
      broadcast_message(socket, "LEAVE", [handle])
    rescue
      log "failed to broadcast LEAVE for clone handle #{handle}"
    end
  end

  def check_token(chat_token)
    sender = @handle_keys[chat_token]
    return !sender.nil?
  end

  def get_handle(chat_token)
    sender = @handle_keys[chat_token]
    return sender
  end

  # server tell a single socket
  def send_message(io, opcode, args)
    msg = opcode + "::!!::" + args.join("::!!::")
    sock_send io, msg
  end

  def sock_send io, msg
    msg = "#{msg}\0"
    log msg
    io.send msg, 0
  end

  # server tell all sockets except
  # if sender is nil then everyone
  def broadcast_message(sender, opcode, args)
    msg = opcode + "::!!::" + args.join("::!!::")
    broadcast msg, sender
  end

  def build_chat_log
    return "" unless @scrollback
    out = ""
    @buffer.each do |msg|
      out += "#{msg[0]}: #{msg[1]}\n"
    end
    out
  end


  def clean_handles
    @handle_keys.each do |k, v|
      if @handle_last_pinged[v] && @handle_last_pinged[v] < Time.now - 10
        log "removed clone handle: #{v}"
        remove_user_by_handle(v)
      end
    end
  end

  def build_handle_list
    return @handles.join("\n")
  end

  # react to allowed commands
  def parse_line(line, io)
    parr = line.split("::!!::")
    command = parr[0]
    if command == "SIGNON"
      handle = parr[1]
      password = parr[2]

      if @handles.include?(handle)
        send_message(io, "ALERT", ["Your handle is in use."])
        io.close
        return
      end

      if handle == nil || handle == ""
        send_message(io, "ALERT", ["You cannot have a blank name."])
        #remove_dead_socket io
        io.close
        return
      end

      if ((@password == password) || ((password === nil) && (@password == "")))
        # uuid are guaranteed unique
        chat_token = rand(36**8).to_s(36)
        @mutex.synchronize do
          @handle_keys[chat_token] = handle
          @socket_keys[io] = chat_token
          # @port_keys[io.peeraddr[1]] = chat_token
          # not on list until pinged.
          @handles << handle
          @sockets << io
        end
        send_message(io, "TOKEN", [chat_token, handle, @server_name])
        broadcast_message(io, "JOIN", [handle])
      else

        send_message(io, "ALERT", ["Password is incorrect."])
        io.close

      end

      return

    end

    # auth
    chat_token = parr.last

    if check_token(chat_token)
      handle = get_handle(chat_token)
      if command == "GETHANDLES"
        send_message(io, "HANDLES", [build_handle_list])
      elsif command == "GETBUFFER"
        buffer = build_chat_log
        send_message(io, "BUFFER", [buffer])
      elsif command == "MESSAGE"
        msg = parr[1]
        message = "#{handle}: #{msg}\n"
        @buffer << [handle, msg]
        broadcast_message(io, "SAY", [handle, msg])
      elsif command == "PING"
        unless @handles.include?(handle)
          @handles << handle
        end
        @handle_last_pinged[handle] = Time.now
      end
    end
  end

  def pong_everyone
    #log "trying to pong"
    unless @sockets.length == 0 && !self.stopped?
      #log "ponging"
      broadcast_message(nil, "PONG", [build_handle_list])
      sleep 5
      clean_handles
    end
  end

  def start_pong_loop
    Thread.new do
      loop do
        sleep 5
        pong_everyone
      end
    end
  end

  #  def disconnecting(clientPort)
  #    log "disconnect event"
  #    ct = @port_keys[clientPort]
  #    handle = @handle_keys[ct]
  #    if handle
  #      log "disconnect removal event"
  #      remove_dead_socket ct
  #    end
  #    super(clientPort)
  #  end
  def starting
    log("GlobalChat2 Server Running")
    start_pong_loop
  end

  def serve(io)
    loop do
      data = ""
      begin
        while line = io.recv(1)
          break if line == "\0"
          data += line
        end
      rescue
        log "recv break removal event"
        remove_dead_socket io #, true
        break
      end
      unless data == ""
        log "#{data}"
        parse_line(data, io)
      end
    end
  end

  def status
    passworded = (self.password != "")
    scrollback = self.scrollback
    log "#{@server_name} running on GlobalChat2 3.0 platform Replay:#{scrollback} Passworded:#{passworded}"
  end

  def log(msg)
    puts msg
  end


  def save_chat_log
    log "saving chatlog"
    @pstore.transaction do
      @pstore[:log] = @buffer
      #p @pstore[:log]
    end

  end

  def load_chat_log
    log "loading chatlog"
    @pstore.transaction(true) do
      @buffer = @pstore[:log] || []
      #p @buffer
    end
  end

end

def ping_nexus(chatnet_name, host, port)
  puts "Pinging NexusNet that I'm Online!!"
  uri = URI.parse("http://nexusnet.herokuapp.com/online")
  query = {:name => chatnet_name, :port => port, :host => host}
  uri.query = URI.encode_www_form( query )
  Net::HTTP.get(uri)
  $published = true
end

def nexus_offline
  puts "Informing NexusNet that I have exited!!!"
  Net::HTTP.get_print("nexusnet.herokuapp.com", "/offline")
end

# at_exit do
#   nexus_offline
#   $gc.save_chat_log
# end

# $gc = GlobalChatServer.new(9994, '0.0.0.0', 1000, $stderr, true)
# $gc.password = "" # set a password here
# $gc.scrollback = true
# $gc.start

# if ENV["RUBY_VERSION"] && ENV["RUBY_VERSION"].include?("1.9")
#   ping_nexus("GlobalChatNet2", "localhost", $gc.port)
# end

# $gc.status

# $gc.join



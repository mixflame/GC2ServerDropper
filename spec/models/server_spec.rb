require 'global_chat_controller'
require 'spec_helper'

describe Server do
  it "is real GC2 server" do
    # p @server
    @server = ServerDropper.create_server("localhost", "YOLOChat", "", false, true)
    sleep 5

    ServerDropper.check_server(@server.host, @server.port).should eq(true)

    ServerDropper.destroy_server @server.id
  end

  it 'can be restarted' do
    @server = ServerDropper.create_server("localhost", "YOLOChat", "", false, true)
    old_pid = @server.pid
    ServerDropper.restart_server @server.id
    new_pid = @server.pid
    old_pid.should != new_pid
  end

  it "it loves to do a drive by on GlobalChatNet" do
    ServerDropper.check_server('globalchat2.net', 9994).should eq(true)
  end

  it 'can restart all servers' do
    old_pid = Server.first.pid
    ServerDropper.restart_all_servers
    new_pid = Server.first.pid
    old_pid.should != new_pid
  end

end
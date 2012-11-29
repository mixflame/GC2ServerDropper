require 'global_chat_controller'
require 'spec_helper'

# SERVER DRIPPER TEST
# i leave no trace

describe Server do

  it "is real GC2 server" do

    @server = ServerDropper.create_server("localhost", "YOLOChat", "", false, true)
    ServerDropper.start_server(@server)

    sleep 5

    ServerDropper.check_server(@server.host, @server.port).should eq(true)

    ServerDropper.destroy_server @server.id
  end

  it 'can be restarted' do
    @server = ServerDropper.create_server("localhost", "YOLOChat", "", false, true)
    sleep 5
    ServerDropper.start_server(@server)
    old_pid = @server.pid
    @server = ServerDropper.restart_server(@server.id)
    new_pid = @server.pid
    old_pid.should_not == new_pid
  end

  it "it loves to do a drive by on GlobalChatNet" do
    ServerDropper.check_server('globalchat2.net', 9994).should eq(true)
  end

  it 'can restart all servers' do
    (0..10).each do |n|
      server = ServerDropper.create_server("localhost", "YOLOChat#{n}", "", false, true)
      ServerDropper.start_server(server)
    end
    old_pid = Server.first.pid
    ServerDropper.restart_all_servers
    new_pid = Server.first.pid
    old_pid.should_not == new_pid
  end

  after do
    Server.all.each do |server|
      ServerDropper.destroy_server server.id
    end
  end

end
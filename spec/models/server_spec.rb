require 'global_chat_controller'
require 'spec_helper'

describe Server do
  before do
    @server = ServerDropper.create_server(12345)
  end
  it "has a port number" do
    @server.port.should eq 12345
  end
  it "is real GC2 server" do
    gcc = GlobalChatController.new
    gcc.handle = "test user"
    gcc.host = @server.host
    gcc.port = @server.port
    gcc.password = @server.password

    gcc.send_message "Hello World"

    the_log = gcc.get_log
    result = the_log.include? "Hello World"
    result.should eq true

    gcc.get_log.should include "Hello World"
  end
end
require 'global_chat_controller'
require 'spec_helper'

describe Server do
  it "is real GC2 server" do
    # p @server
    @server = ServerDropper.create_server("localhost", "YOLOChat", "", false, true)

    sleep 5

    gcc = GlobalChatController.new
    gcc.handle = "test user"
    gcc.host = @server.host
    gcc.port = @server.port
    gcc.password = @server.password

    gcc.nicks = []
    gcc.chat_buffer = ""

    gcc.sign_on

    sleep 3

    gcc.chat_token.should_not be_nil
    ServerDropper.destroy_server @server.id
  end

  it "is loves to do a drive by on GlobalChatNet" do
    gcc = GlobalChatController.new
    gcc.handle = "test user"
    gcc.host = 'globalchat2.net'
    gcc.port = 9994
    gcc.password = ""

    gcc.nicks = []
    gcc.chat_buffer = ""

    gcc.sign_on

    sleep 5

    gcc.chat_buffer.should_not be_nil

    gcc.sign_out
  end

end
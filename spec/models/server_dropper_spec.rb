require 'spec_helper'

describe ServerDropper do
  it "can create a new GC2 server on a port" do
    port = 1234
    server = ServerDropper.create_server(port)
    server.class.should eq Server
    server.port.should eq port
  end
end
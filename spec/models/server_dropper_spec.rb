require 'spec_helper'

describe ServerDropper do
  it "can create a new GC2 server on a port" do
    server = ServerDropper.create_server("localhost", "YOLOChat", "", false, true)
    server.class.should eq Server
  end
end
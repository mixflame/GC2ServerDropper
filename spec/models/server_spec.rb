require 'spec_helper'

describe Server do
  before do
    @server = ServerDropper.create_server(12345)
  end
  it "has a port number" do
    @server.port.should eq 12345
  end
end
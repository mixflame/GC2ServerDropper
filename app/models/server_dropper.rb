class ServerDropper < ActiveRecord::Base
  attr_accessible :host, :port

  def self.create_server port
    Server.new(:port=>port)
  end
end

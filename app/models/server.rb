class Server < ActiveRecord::Base
  attr_accessible :buffer_replay, :host, :name, :password, :port, :private, :server_dropper_id

  

end

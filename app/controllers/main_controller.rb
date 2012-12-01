class MainController < ApplicationController
  before_filter :check_heroku, :except => :welcome

  def welcome
    #landing
  end

  # only called by heroku
  def check_server
    host = params[:host]
    port = params[:port]
    begin
      # password must be blank
      online = ServerDropper.check_server(host, port)
      @status = online ? 200 : 404
    rescue
      @status = 404
    ensure
      render :text => @status, :status => @status
    end
  end

  # creates server, doesnt start it
  def drop_server
    # admin login
    email = params[:email]
    # admin password (random)
    pass = rand(36**8).to_s(36)

    host = [Forgery::Basic.color, Forgery::Address.street_name.split(" ").first, rand(100)].join("-").downcase
    host += ".globalchat2.net"
    name = "#{Forgery::Address.street_name.split(" ").first}Chat"
    password = ""
    is_private = false
    has_scrollback = true
    server = ServerDropper.create_server host, name, password, is_private, has_scrollback, email, pass
    sleep 3
    server.start
    # easy reply, nexus will perform true check server security
    if server
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 404
    end
  end

  private

  def check_heroku
    sender = request.env['REMOTE_ADDR']
    require 'resolv'
    hostname = Resolv.getname(sender)
    logger.info "sender: #{hostname}"
    raise 'unauthorized' unless sender.match('amazonaws.com')
  end

end

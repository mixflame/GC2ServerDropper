class MainController < ApplicationController
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
      render :nothing => true, :status => @status
    end
  end

  # actually create the server
  # dont care if private or passworded
  # just wanna be sure it worked
  def drop_server
    # raise 'unauthorized' unless params[:temporary] == "0BV10U5P4SSW0RD" # back end password to use this api
    host = params[:host]
    name = params[:name]
    password = params[:password]
    is_private = params[:private] == "true"
    has_scrollback = params[:scrollback] == "true"
    server = ServerDropper.create_server host, name, password, is_private, has_scrollback
    # for now, start it.. ipn security later and bypass
    sleep 3
    server.start
    # easy reply, nexus will perform true check server security
    if server.pid
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 404
    end
  end

end

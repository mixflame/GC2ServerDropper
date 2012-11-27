class MainController < ApplicationController
  def welcome
    #landing
  end

  def check_server
    host = params[:host]
    port = params[:port]
    begin
      online = ServerDropper.check_server(host, port)
      @status = online ? 200 : 404
    rescue
      @status = 404
    ensure
      render :nothing => true, :status => @status
    end
  end

end

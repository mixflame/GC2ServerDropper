class ServerMailer < ActionMailer::Base
  default :from => "globalchat2@globalchat2.net"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.server_mailer.send_login_deetz.subject
  #
  def send_login_deetz(email, pass, host, port)
    @pass = pass
    @email = email
    @host = host
    @port = port
    mail :to => email, :subject => "Thank you for buying a hosted GC2 server!"
  end
end

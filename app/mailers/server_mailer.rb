class ServerMailer < ActionMailer::Base
  default :from => "globalchat2@globalchat2.net"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.server_mailer.send_login_deetz.subject
  #
  def send_login_deetz(email, pass)
    @pass = pass
    @email = email
    mail :to => email
  end
end

require 'sendgrid-ruby'
require 'config_env'

module EmailHelper

  def send_reg_email(to,url)
    text = "In case you can't read html, copy this link into the address bar of your browser: " + url
    html = '<html><body><h1>Click <a href=' + url + '>here</a> to activate your account.</h1></body></html>'

    client = SendGrid::Client.new(api_user: ENV['SG_USER'], api_key: ENV['SG_PW'])
    
    email = SendGrid::Mail.new do |m|
      m.to = to
      m.from = 'acctservices.emfg@gmail.com'
      m.from_name = 'Account Services at Enigma Manufacturing'
      m.subject = 'Activate your account'
      m.text = text
      m.html = html
    end
    client.send(email)
  end

end

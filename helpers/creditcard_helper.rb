require 'jwt'

module CreditCardHelper
  def validate_card(card_num)
    creditcard = CreditCard.new
    creditcard.number = card_num
    creditcard.validate_checksum ? validation="Ok" : validation="mispelled"
    { :card => creditcard.number, :validated => validation }
  end

  def new_card(ccnum,owner,exp_date,credit_nt)

    mycc = CreditCard.new(:number => ccnum.to_s,:expiration_date => exp_date.to_s,:owner => owner.to_s,:credit_network => credit_nt.to_s)

    unless mycc.validate_checksum then
       { :message => "We could not store your credit card. :("}
    else
      mycc.save
      { :message => "We stored your credit card! :)"}

      #{ :number => mycc.number,
      #  :owner => mycc.owner,
      #  :expiration_date => mycc.expiration_date,
      #  :credit_network => mycc.credit_network}
    end
  end

  #def login_user(user)
  #session[:user_id]=user.id
  #redirect '/'
  #end

  def login_user(user)
  payload = {user_id: user.id}
  token = JWT.encode payload, ENV['TK_KEY'], 'HS256'
  session[:auth_token] = token
  redirect '/'
  end

  def find_user_by_token(token)
  return nil unless token
  decoded_token = JWT.decode token, ENV['TK_KEY'], true
  payload = decoded_token.first
  User.find_by_id(payload["user_id"])
  end

  def logout_user
  #session[:user_id]=nil
  session[:auth_token] = nil
  flash[:notice] = "You have been logged out. Now get out."
  redirect '/'
  end
end

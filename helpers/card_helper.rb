module CreditCardHelper
  def validate_card(number)
    creditcard = CreditCard.new
    creditcard.number = number
    {card_num: creditcard.number , validated: creditcard.validate_checksum}
  end
  
  def login_user(user)
    session[:user_id] = user.id
    redirect '/'
  end

end

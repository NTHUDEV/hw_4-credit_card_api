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

  def new_card(number, owner, expiration_date, network)
    cc = CreditCard.new(:number => number,
                          :expiration_date => expiration_date,
                          :owner => owner, 
                          :credit_network => network)
    unless cc.validate_checksum then
      {:status => 'Transaction Incomplete, please check the values'}
    else
      cc.save
      {:status => 'New Credit Card with number ' + cc.number + ' has been saved'}
    end
  end     
end

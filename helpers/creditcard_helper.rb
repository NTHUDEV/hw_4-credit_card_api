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
end

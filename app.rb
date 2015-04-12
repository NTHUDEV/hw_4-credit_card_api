require 'sinatra'
require './lib/credit_card.rb'

class CreditCardAPI < Sinatra::Base

get '/' do
"CreditCardAPI by Enigma Manufacturing is up and running."
end

get '/api/v1/credit_card/validate' do
  creditcard = CreditCard.new(params[:card_number], nil, nil, nil)
  {card: params[:card_number].to_s, validated: creditcard.validate_checksum}.to_json

end

end

require 'sinatra'
require_relative './model/credit_card.rb'
require 'json'
require 'config_env'

class CreditCardAPI < Sinatra::Base
  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end
  get '/' do
    halt 200, 'APP Running and Working'
  end

  get '/api/v1/credit_card/validate' do
    creditcard = CreditCard.new
    creditcard.number = params[:card_number]
    {card: params[:card_number], validated: creditcard.validate_checksum}.to_json
  end
 
  post '/api/v1/credit_card' do
    request_json = request.body.read
    begin
      unless request_json.empty? 
        req = JSON.parse(request_json)
      end 
      cc = CreditCard.new(:number => req['number'],
                          :expiration_date => req['expiration_date'],
                          :owner => req ['owner'], 
                          :credit_network => req['credit_network'])
      halt 400 if !cc.validate_checksum 
      cc.save
      halt 201, 'status 201: Well done Jarvis'
    rescue Exception=>e
      halt 410, e
    end
  end  

  get '/index' do
    begin
      cards = CreditCard.all
      halt 200, cards.to_json
    rescue
      halt 500
    end
  end
end

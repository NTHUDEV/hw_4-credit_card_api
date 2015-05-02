require 'sinatra'
require 'rbnacl/libsodium'
require 'config_env'
require_relative './model/credit_card.rb'
require 'haml'
require_relative 'helpers/creditcard_helper'
#require './lib/credit_card.rb'

class CreditCardAPI < Sinatra::Base
include CreditCardHelper
configure :development, :test do
  ConfigEnv.path_to_config("./config/config_env.rb")
  require 'hirb'
  Hirb.enable
end

#API
get '/api/v1/' do
  "CreditCardAPI by Enigma Manufacturing is up and running."
end

get '/api/v1/index' do
begin

  halt 200, CreditCard.all.to_json

rescue Exception => e
  halt 500, "All these moments will be lost in time like tears in the rain. -Roy Batty. Please punch your app dev in the face and show this #{e}."
end

end

get '/api/v1/credit_card/validate' do
  #creditcard = CreditCard.new(params[:card_number], nil, nil, nil)
  creditcard = CreditCard.new
  creditcard.number = params[:card_number]
  {card: creditcard.number, validated: creditcard.validate_checksum}.to_json
end

post '/api/v1/credit_card' do
  begin
    request_json = request.body.read
    req = JSON.parse(request_json)
    mycc = CreditCard.new(:number => req['number'].to_s,:expiration_date => req['expiration_date'].to_s,:owner => req['owner'].to_s,:credit_network => req['credit_network'].to_s)
    halt 400, "Whoa! Did you made a mistake or are you trying to trick the system?" unless mycc.validate_checksum
    mycc.save
    halt 201, "Welcome to the wonderful family of Enigma Mfg. We shall splurge on fancy equipment for our office with your credit card."
  rescue
    halt 410, "I'm sorry Dave, I'm afraid I can't do that. -HAL9000"
  end
end

#web app
get '/' do
  haml :index
end

get '/validate' do
  haml :validate
end

post '/validate' do
  card_num = params[:credit_card_num].to_s unless params[:credit_card_num].empty?
  @validation_results = validate_card(card_num)
  haml :validate
end

get '/newcard' do
  haml :newcard
end

post '/newcard' do
  cc_num = params[:credit_card_num].to_s unless params[:credit_card_num].empty?
  cc_owner = params[:cc_owner].to_s unless params[:cc_owner].empty?
  cc_exp_date = params[:cc_exp_date].to_s unless params[:cc_exp_date].empty?
  cc_credit_nt = params[:cc_net].to_s unless params[:cc_net].empty?
  @creation_results = new_card(cc_num, cc_owner, cc_exp_date, cc_credit_nt)
  haml :newcard
end
end

require 'sinatra'
require 'rbnacl/libsodium'
require 'config_env'
require_relative './model/credit_card.rb'
require_relative './model/user.rb'
require 'haml'
require_relative 'helpers/creditcard_helper'
#require './lib/credit_card.rb'

class CreditCardAPI < Sinatra::Base
include CreditCardHelper
use Rack::Session::Cookie
enable :logging
configure :development, :test do
  ConfigEnv.path_to_config("./config/config_env.rb")
  require 'hirb'
  Hirb.enable
end

before do
@current_user = session[:user_id] ? User.find_by_id(session[:user_id]) : nil
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

get '/login' do
  haml :login
end

post '/login' do
  username = params[:username]
  password = params[:password]

  user = User.authenticate!(username,password)
  user ? login_user(user) : redirect('/')
end

get '/logout' do
  logout_user
end

get '/register' do
  haml :register
end

post '/register' do
  logger.info('REGISTER')
  username = params[:username]
  email = params[:email]
  password = params[:password]
  password_confirm = params[:password_confirm]
  address = params[:address]
  full_name = params[:full_name]
  dob = params[:dob]
  begin
    if password == password_confirm
      new_user = User.new(username: username, email: email)
      new_user.password = password
      new_user.field_encrypt(address,:address)
      new_user.field_encrypt(full_name,:full_name)
      new_user.field_encrypt(dob,:dob)
      #new_user.save! ? login_user(new_user) : fail('Could not create new user')
      new_user.save! ? redirect('/login') : fail('Could not create new user')
    else
      fail 'Passwords do not match'
    end
  rescue => e
    logger.error(e)
    redirect '/register'
  end
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

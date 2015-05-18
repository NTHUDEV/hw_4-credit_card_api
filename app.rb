require 'sinatra'
require 'rbnacl/libsodium'
require 'config_env'
require_relative './model/credit_card.rb'
require_relative './model/user.rb'
require 'haml'
require_relative 'helpers/creditcard_helper'
require 'rack-flash'
#require './lib/credit_card.rb'

class CreditCardAPI < Sinatra::Base
include CreditCardHelper
#use Rack::Session::Cookie
#enable :logging

configure :development, :test do
  ConfigEnv.path_to_config("./config/config_env.rb")
  require 'hirb'
  Hirb.enable
end

configure do
  use Rack::Session::Cookie, secret: ENV['TK_KEY']
  enable :logging
  use Rack::Flash, :sweep => true
end


#before do
#@current_user = session[:user_id] ? User.find_by_id(session[:user_id]) : nil
#end

before do
@current_user = find_user_by_token(session[:auth_token])
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

  begin
    if params[:password] == params[:password_confirm]
      params[:username] != "" && params[:email] != nil ? new_user = User.new(username: params[:username], email: params[:email]) : fail(flash[:error] = "All fields are required")
      params[:password] != "" ? new_user.password = params[:password] : fail(flash[:error] = "Nice try smartass.")
      params[:address] != "" ? new_user.field_encrypt(params[:address],:address) : fail(flash[:error] = "So...where do you live?")
      params[:full_name] != "" ? new_user.field_encrypt(params[:full_name],:full_name) : fail(flash[:error] = "We require a full name.")
      params[:dob] != "" ? new_user.field_encrypt(params[:dob],:dob) : fail(flash[:error] = "DOB is blank")

      #new_user.save! ? redirect('/login') : fail(flash[:error] = "All fields are required")
      send_activation_email(params[:username],params[:password],params[:email],params[:address],params[:full_name],params[:dob]) ? redirect('/success') : fail(flash[:error] = "All fields are required")

    else
      fail flash[:error] = "Passwords do not match."
    end
  rescue => e
    logger.error(e)
    flash[:error] = "Well this happened: #{e}"
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

get '/success' do
  haml :registration_success
end

get '/activate' do
  @activation_results = create_user(params[:tk])
  haml :activate
end
end

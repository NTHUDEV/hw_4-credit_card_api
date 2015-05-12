require 'sinatra'
require_relative './model/credit_card.rb'
require 'json'
require 'config_env'
require_relative './helpers/card_helper.rb'
require 'rack'

class CreditCardAPI < Sinatra::Base
  include CreditCardHelper
  use Rack::Session::Cookie
  enable :loggin 
  
  configure :development, :test do
    require 'hirb'
    Hirb.enable
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end
  
  before do
    @current_user = session[:user_id] ? User.find_by_id(session[:usser_id]) : nil
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

  get 'api/v1/index' do
    begin
      cards = CreditCard.all
      halt 200, cards.to_json
    rescue
      halt 500
    end
  end

  get '/' do
    haml :index
  end
  
  get '/login' do
    haml :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    user = User.authenticate!(username, password)
    user ? login_user(user) : redirect('/login')
  end

  get '/logout' do
    session[:user_id] = nil
    redirect '/'
  end

  get '/register' do
    haml :register
  end

  post '/register' do
    logger.info('REGISTER')
    username = params[:username]
    fullname = params[:fullname]
    dob = params[:dob]
    email = params[:email]
    address = params[:address]
    password = params[:password]
    password_confirm = params[:password_confirm]
    begin
      if password == password_confirm
        new_user = User.new(username: username, email: email)
        new_user.password = password
        new_user.dob = new_user.encrypt(dob)
        new_user.fullname = new_user.encrypt(fullname)
        new_user.address = new_user.encrypt(address)
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
    begin
      cc_num = params[:card_number].to_s unless params[:card_number].empty?
      @validation = validate_card(cc_num)
      haml :validate
    rescue => 3
      puts e
      halt 400, "Check if credit Card Number are Intergers"
    end
  end

  
end

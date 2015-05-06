require_relative 'spec_helper'

describe 'Credit Card APP Secure' do
  describe 'Getting the root of the service' do
    it 'should return ok' do
      get '/'
      last_response.body.must_include 'APP Running and Working'
      last_response.status.must_equal 200
    end
  end

  describe 'Validating a Card number' do
    before do
      CreditCard.delete_all
    end
    it 'should return false for a invalid card' do
      get '/api/v1/credit_card/validate?card_number=4024097178888052' 
        results = JSON.parse(last_response.body)
        results['validated'].must_equal false
    end

    it 'should return true for a valid card' do
      get '/api/v1/credit_card/validate?card_number=4916603231464963'
        results = JSON.parse(last_response.body)
        results['validated'].must_equal true
    end
  end
  
  describe 'Creating a Credit Card Object on table' do
    before do
      CreditCard.delete_all
    end
    it 'should create card object and record on table' do
        req_header = {'CONTENT_TYPE' => 'application/json'}
        req_body = { :number => '5192234226081802', :expiration_date => '2017-04-19', :owner => 'Cheng-Yu Hsu', :credit_network => 'Visa'}  
        post '/api/v1/credit_card', req_body.to_json, req_header       
          last_response.status.must_equal 201
          last_response.body.must_include 'status 201: Well done Jarvis'
          cc = CreditCard.first
          cc.wont_be_nil
    end

    it 'should encrypt/decrypt the card number to the database' do
      req_header = {'CONTENT_TYPE'=>'application/json'}
      req_body = { :number => '5192234226081802', :expiration_date => '2017-04-19', :owner => 'Cheng-Yu Hsu', :credit_network => 'Visa'}  
      post '/api/v1/credit_card', req_body.to_json, req_header
      cc = CreditCard.first
      cc.number.wont_equal cc.encrypted_number
      cc.number.must_equal '5192234226081802'
    end
  end      
end

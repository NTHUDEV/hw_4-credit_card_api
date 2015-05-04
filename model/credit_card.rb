require_relative '../lib/luhn_validator.rb'
require 'sinatra/activerecord'
require_relative '../environments.rb'
require 'json'
require 'openssl'
require 'rbnacl/libsodium'
require 'config_env'
require 'base64'

# Class CreditCard
class CreditCard < ActiveRecord::Base
  # TODO: mixin the LuhnValidator using an 'include' statement
  include LuhnValidator
  # instance variables with automatic getter/setter methods
  # attr_accessor :number, :expiration_date, :owner, :credit_network
  #def initialize(number, expiration_date, owner, credit_network)
    # TODO: initialize the instance variables listed above (do not forget the '@')
   # @number = number
   # @expiration_date = expiration_date
   # @owner = owner
    #@credit_network = credit_network
 # end
  # returns json string
  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
  end

  def number=(numb)
    secret_box = RbNaCl::SecretBox.new(key)
    nonce = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
    encrypted_numb = secret_box.encrypt(nonce, numb)
    self.nonce = Base64.urlsafe_encode64(nonce)
    self.encrypted_number = Base64.urlsafe_encode64(encrypted_numb)
  end

  def number
    secret_box = RbNaCl::SecretBox.new(key)
    nonce = Base64.urlsafe_decode64(self.nonce)
    encrypted_numb = Base64.urlsafe_decode64(self.encrypted_number)
    secret_box.decrypt(nonce, encrypted_numb)
  end

  def to_json
    # TODO: setup the hash with all instance vairables to serialize into json
    { number: number, expiration_date: expiration_date, owner: owner, credit_network: credit_network }.to_json
  end
  # returns all card information as single string
  def self.to_s
    "#{:number_encrypted}, #{:expiration_date}, #{:owner}, #{:credit_network}"
    #self.to_json
  end

  # return a new CreditCard object given a serialized (JSON) representation
  def self.from_s(card_s)
    # TODO: deserializing a CreditCard object
    parsed = JSON.parse(card_s)
    new(parsed['number'], parsed['expiration_date'], parsed['owner'], parsed['credit_network'])
  end
  # return a hash of the serialized credit card object
  def hash
    # TODO: Produce a hash (using default hash method) of the credit card's
    #       serialized contents.
    #       Credit cards with identical information should produce the same hash.
    to_s.hash
  end
  # return a cryptographically secure hash
  def hash_secure
    # TODO: Use sha256 from openssl to create a cryptographically secure hash.
    #       Credit cards with identical information should produce the same hash.
    sha256 = OpenSSL::Digest::SHA256.new
    sha256.digest(to_s).unpack('H*')
  end
end

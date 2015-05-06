require_relative '../lib/luhn_validator.rb'
require 'sinatra/activerecord'
require_relative '../environments'
require 'json'
require 'openssl'
require 'rbnacl/libsodium'
require 'base64'

# Class CreditCard
class CreditCard < ActiveRecord::Base
  # TODO: mixin the LuhnValidator using an 'include' statement
  include LuhnValidator
  # instance variables with automatic getter/setter methods
  #attr_accessor :number, :expiration_date, :owner, :credit_network

=begin
  def initialize(number, expiration_date, owner, credit_network)
    #TODO: initialize the instance variables listed above (do not forget the '@')
    @number = number
    @expiration_date = expiration_date
    @owner = owner
    @credit_network = credit_network
  end
=end

  # returns json string
  def to_json
    # TODO: setup the hash with all instance vairables to serialize into json
    { number: number, expiration_date: expiration_date, owner: owner, credit_network: credit_network }.to_json
  end

  # returns all card information as single string
  def to_s
    to_json
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

  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])
    #ENV['DB_KEY'].dup.force_encoding Encoding::BINARY
  end

  def number=(cc_num)
    box_closed = RbNaCl::SecretBox.new(key)
    nonce = RbNaCl::Random.random_bytes(box_closed.nonce_bytes)
    encrypt_num = box_closed.encrypt(nonce,cc_num)

    #encoded using base64 to eliminate encoding issues
    self.nonce = Base64.urlsafe_encode64(nonce)
    self.encrypted_number = Base64.urlsafe_encode64(encrypt_num)
  end

  def number
    box_open = RbNaCl::SecretBox.new(key)
    #decoded using base64 to eliminate encoding issues
    nonce = Base64.urlsafe_decode64(self.nonce)
    encrypt_num = Base64.urlsafe_decode64(self.encrypted_number)
    box_open.decrypt(nonce, encrypt_num)
  end
end

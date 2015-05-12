require 'sinatra/activerecord'
require 'protected_attributes'
require_relative '../environments'
require 'rbnacl/libsodium'
require 'base64'

class User < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
  validates :fullname, presence: true, uniqueness: true
  validates :email, presence: true, format: /@/
  validates :address, presence: true
  validates :dob, presence: true
  validates :hashed_password, presence: true
  

  attr_accessible :username, :email
  
  def password=(new_password)
    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    digest = self.class.hash_password(salt, new_password)
    self.salt = Base64.urlsafe_encode64(salt)
    self.hashed_password = Base64.urlsafe_encode64(digest)
  end

  def key
    Base64.urlsafe_decode64(ENV['DB_KEY'])   
  end

  def encrypt(data)
    secret_box = RbNaCl::SecretBox.new(key)
    nonce_data = RbNaCl::Random.random_bytes(secret_box.nonce_bytes)
    self.nonce_data ||= Base64.urlsafe_encode64(nonce_data)
    encrypted_data = secret_box.encrypt(Base64.urlsafe_decode64(self.nonce_data), data)
    return Base64.urlsafe_encode64(encrypted_data)
  end

  def decrypt(encrypted)
    secret_box = RbNaCl::SecretBox.new(key)
    nonce_data = Base64.urlsafe_decode64(self.nonce_data)
    encrypted_data = Base64.urlsafe_decode64(encrypted)
    return secret_box.decrypt(nonce_data, encrypted_data)
  end

  def self.authenticate!(username, login_password)
    user = User.find_by_username(username)
    user && user.password_matches?(login_password) ? user : nil
  end

  def password_matches?(try_password)
    salt = Base64.urlsafe_decode64(self.salt)
    attempted_password = self.class.hash_password(salt, try_password)
    hashed_password == Base64.urlsafe_encode64(attempted_password)
  end

  def self.hash_password(salt, pwd)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64
    RbNaCl::PasswordHash.scrypt(pwd, salt, opslimit, memlimit, digest_size)
  end
end

  

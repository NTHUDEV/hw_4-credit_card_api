require 'openssl'
require 'json'
# Module AESCipher
module AesCipher
  def self.encrypt(document, key)
    # TODO: Return JSON string of array: [iv, ciphertext]
    #       where iv is the random intialization vector used in AES
    #       and ciphertext is the output of AES encryption
    # NOTE: Use hexadecimal strings for output so that it is screen printable
    #       Use cipher block chaining mode only!
    doc = document.to_s
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    cipher.key = (key.to_s * cipher.key_len).to_s
    iv = cipher.random_iv
    ciphertext = cipher.update(doc) + cipher.final
    { initial_vector: iv.unpack('H*'), ciphertext: ciphertext.unpack('H*') }.to_json
  end

  def self.decrypt(aes_crypt, key)
    # TODO: decrypt from JSON output (aes_crypt) of encrypt method above
    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = (key.to_s * decipher.key_len).to_s
    decipher.iv = JSON.parse(aes_crypt)['initial_vector'].pack('H*')
    decipher.update(JSON.parse(aes_crypt)['ciphertext'].pack('H*')) + decipher.final
  end
end

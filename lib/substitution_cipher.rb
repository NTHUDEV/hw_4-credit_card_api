module SubstitutionCipher
  # Module Caesar
  module Caesar
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)
      # TODO: encrypt string using caeser cipher
      phrase_arr = document.to_s.split('')
      phrase_arr.map! do |char|
        keyspace = char.ord + key
        if keyspace > 126
          keyspace -= 95
        end
        char = keyspace.chr
      end
      phrase_arr.join
    end

    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using caeser cipher
      phrase_arr = document.to_s.split('')
      phrase_arr.map! do |char|
        keyspace = char.ord - key
        if keyspace < 32
          keyspace += 95
        end
        char = keyspace.chr
      end
      phrase_arr.join
    end
  end
  # Module Permutation
  module Permutation
    # Encrypts document using key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.encrypt(document, key)
      # TODO: encrypt string using caeser cipher
      rand_encrypt = Random.new(key)
      phrase_arr = document.to_s.split('')
      index_key = 0
      keyspace = {}      
      until keyspace.length > 126 do
        random_char = rand_encrypt.rand(127)
        if keyspace.value? random_char
          # Do nothing
        else
           keyspace[index_key] = random_char
           index_key += 1
        end
      end
      phrase_arr.map! { |c| keyspace[c.ord].chr }.join
    end
    # Decrypts String document using integer key
    # Arguments:
    #   document: String
    #   key: Fixnum (integer)
    # Returns: String
    def self.decrypt(document, key)
      # TODO: decrypt string using caeser cipher
      rand_decrypt = Random.new(key)
      phrase_arr = document.to_s.split('')
      index_key = 0
      keyspace = {}
      until keyspace.length > 126 do
        random_char = rand_decrypt.rand(127)
        if keyspace.value? random_char
          # Do nothing
        else
           keyspace[index_key] = random_char
           index_key += 1
        end
      end
      phrase_arr.map! { |c| keyspace.key(c.ord).chr }.join
    end
  end
end

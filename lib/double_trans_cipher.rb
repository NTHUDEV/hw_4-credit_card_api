require_relative './Array'
# Module DoubleTransposition
module DoubleTranspositionCipher
  def self.encrypt(document, key)
    # TODO: FILL THIS IN!
    ## Suggested steps for double transposition cipher
    # 1. find number of rows/cols such that matrix is almost square
    # 2. break plaintext into evenly sized blocks
    # 3. sort rows in predictibly random way using key as seed
    # 4. sort columns of each row in predictibly random way
    # 5. return joined cyphertext
    aleatorio = Random.new(key)
    doc = document.to_s
    size = Math.sqrt(doc.length).ceil
    relleno = aleatorio.rand(127)
    matrix = []
    until doc.length % size == 0 do doc.insert(0, relleno.chr) end
    doc.chars.map.each_slice(size) { |c| matrix << c }
    matrix.shuffle!(random: Random.new(key))
    matrix.map { |d| d.shuffle!(random: Random.new(key)) }    
    matrix.join
  end

  def self.decrypt(ciphertext, key)
    # TODO: FILL THIS IN!
    aleatorio = Random.new(key)
    size = Math.sqrt(ciphertext.length).ceil
    relleno = aleatorio.rand(127)
    matrix = []
    ciphertext.chars.map.each_slice(size) { |c| matrix << c }
    matrix.map! { |c| c.map { |i| i.ord } }
    matrix.map! { |d| d.unshuffle(random: Random.new(key)) }
    matrix = matrix.unshuffle(random: Random.new(key))
    matrix.map! { |c| c.map { |i| i.chr } }
    matrix.join.gsub(relleno.chr, '')
  end
end

# Module LuhnValidator
module LuhnValidator
  # Validates credit card number using Luhn Algorithm
  # arguments: none
  # assumes: a local String called 'number' exists
  # returns: true/false whether last digit is correct
  def validate_checksum
    nums_a = number.to_s.chars.map(&:to_i)
    # TODO: use the integers in nums_a to validate its last check digit
    index = -1
    double = []
    sum = 0
    until nums_a[index].nil?
      if index.even?
        num_double = nums_a[index] * 2
        if num_double > 9
          double << (num_double.to_s)[0].to_i + (num_double.to_s)[1].to_i
        else
          double << num_double
        end
      else
        double << nums_a[index]
      end
      index += -1
    end
    double.each { |x| sum += x }
    sum % 10 == 0 ?  true : false
  end
end

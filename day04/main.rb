require 'test/unit'

extend Test::Unit::Assertions

# Return next increment number so that following digits appear in increasing order.
# For instance 101 will become 111 instead of 101.
def next_increment(number)
  index = -1
  number.digits.reverse.each_cons(2) do |leading, trailing|
    index += 1
    if trailing < leading
      number = number.digits.reverse.fill(leading, index).join.to_i
    end
  end
  number
end

# Return true if password contains two consecutive digits.
def two_consecutive_digits?(password)
  password.to_s.match?(/(\d)\1/)
end

# Return true if password only contains one pair of two consecutive digits.
# Precondition is that password has digits in increasing order.
def only_two_consecutive_digits?(password)
  result = password.digits.inject(Hash.new(0)) { |result, digit| result[digit] += 1; result}
  result.has_value?(2)
end

def count_valid_passwords(start, stop, criteria_method)
  current = next_increment(start)
  password_count = 0
  while current <= stop do
    password_count += 1 if criteria_method.call(current)
    current = next_increment(current + 1)
  end
  password_count
end

assert_equal(9, next_increment(9))
assert_equal(11, next_increment(10))
assert_equal(111, next_increment(109))
assert_equal(356666, next_increment(356261))

input = File.read('input')
start, stop = input.split('-').map(&:to_i)
result = count_valid_passwords(start, stop, Kernel.method(:two_consecutive_digits?))
puts "First answer: #{result}"
result = count_valid_passwords(start, stop, Kernel.method(:only_two_consecutive_digits?))
puts "Second answer: #{result}"

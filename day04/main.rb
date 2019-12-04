require 'test/unit'
require 'byebug'

extend Test::Unit::Assertions

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

def two_consecutive_numbers?(password)
  password.match?(/(\d)\1/)
end

assert_equal(9, next_increment(9))
assert_equal(11, next_increment(10))
assert_equal(111, next_increment(109))
assert_equal(356666, next_increment(356261))

input_start = 356261
input_stop = 846303

current = next_increment(input_start)
password_count = 0
while current <= input_stop do
  password_count += 1 if two_consecutive_numbers?(current.to_s)
  current = next_increment(current + 1)
end

puts password_count

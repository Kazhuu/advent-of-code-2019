require 'test/unit'

extend Test::Unit::Assertions

def add_opcoce(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = get_params(ram, pointer, arg1_immediate, arg2_immediate).reduce(:+)
  pointer + 4
end

def multiply_opcode(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = get_params(ram, pointer, arg1_immediate, arg2_immediate).reduce(:*)
  pointer + 4
end

def input_opcode(ram, pointer, input)
  ram[ram[pointer + 1]] = input.pop
  pointer + 2
end

def output_opcode(ram, pointer, output, arg1_immediate)
  param = get_param(ram, pointer + 1, arg1_immediate)
  output.push(param)
  pointer + 2
end

def jump_if_true(ram, pointer, arg1_immediate, arg2_immediate)
  first, second = get_params(ram, pointer, arg1_immediate, arg2_immediate)
  return second unless first.zero?
  pointer + 3
end

def jump_if_false(ram, pointer, arg1_immediate, arg2_immediate)
  first, second = get_params(ram, pointer, arg1_immediate, arg2_immediate)
  return second if first.zero?
  pointer + 3
end

def less_than(ram, pointer, arg1_immediate, arg2_immediate)
  first, second = get_params(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = if first < second
                            1
                          else
                            0
                          end
  pointer + 4
end

def equals(ram, pointer, arg1_immediate, arg2_immediate)
  first, second = get_params(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = if first == second
                            1
                          else
                            0
                          end
  pointer + 4
end

def get_params(ram, pointer, arg1_immediate, arg2_immediate)
  [get_param(ram , pointer + 1, arg1_immediate), get_param(ram , pointer + 2, arg2_immediate)]
end

def get_param(ram, pointer, immediate)
  if immediate
    ram[pointer]
  else
    ram[ram[pointer]]
  end
end

def decode_opcode(opcode)
  digits = opcode.digits
  [digits[0..1].reverse.join.to_i, digits[2] == 1, digits[3] == 1]
end

def execute_program(ram, input = [])
  output = []
  instruction_pointer = 0
  while ram[instruction_pointer] != 99 do
    opcode, arg1_immediate, arg2_immediate = decode_opcode(ram[instruction_pointer])
    instruction_pointer = if opcode == 1
      add_opcoce(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 2
      multiply_opcode(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 3
      input_opcode(ram, instruction_pointer, input)
    elsif opcode == 4
      output_opcode(ram, instruction_pointer, output, arg1_immediate)
    elsif opcode == 5
      jump_if_true(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 6
      jump_if_false(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 7
      less_than(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 8
      equals(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    else
      raise "invalid opcode"
    end
  end
  output
end

assert_equal([2, false, false], decode_opcode(2))
assert_equal([2, false, true], decode_opcode(1002))
assert_equal([1, true, false], decode_opcode(101))
assert_equal([1, true, true], decode_opcode(1101))
assert_equal([], execute_program([1002,4,3,4,33]))
# Output is 1 if input is equal to 8 in position mode.
assert_equal([0], execute_program([3,9,8,9,10,9,4,9,99,-1,8], [7]))
assert_equal([1], execute_program([3,9,8,9,10,9,4,9,99,-1,8], [8]))
assert_equal([0], execute_program([3,9,8,9,10,9,4,9,99,-1,8], [9]))
# Output is 1 if input is equal to 8 in immediate mode.
assert_equal([0], execute_program([3,3,1108,-1,8,3,4,3,99], [7]))
assert_equal([1], execute_program([3,3,1108,-1,8,3,4,3,99], [8]))
assert_equal([0], execute_program([3,3,1108,-1,8,3,4,3,99], [9]))
# Ouput is 1 if input is less than 8 in position mode.
assert_equal([0], execute_program([3,9,7,9,10,9,4,9,99,-1,8], [8]))
assert_equal([1], execute_program([3,9,7,9,10,9,4,9,99,-1,8], [7]))
# Output is 1 if input is less than 8 in immediate mode.
assert_equal([0], execute_program([3,3,1107,-1,8,3,4,3,99], [8]))
assert_equal([1], execute_program([3,3,1107,-1,8,3,4,3,99], [7]))
# Test jump in position mode.
# Output is 0 if input was zero or 1 if if input was non-zero.
assert_equal([0], execute_program([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0]))
assert_equal([1], execute_program([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [1]))
# Test jump in immediate mode.
# Output is 0 if input was zero or 1 if if input was non-zero.
assert_equal([0], execute_program([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [0]))
assert_equal([1], execute_program([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [1]))
# Output 999 if input < 8, 1000 input == 8 and 1001 input > 8.
ram = [
  3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
  1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
  999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
]
assert_equal([999], execute_program(ram.dup, [7]))
assert_equal([1000], execute_program(ram.dup, [8]))
assert_equal([1001], execute_program(ram.dup, [9]))

ram = File.read('input').split(',').map(&:to_i)

puts "first puzzle:"
output = execute_program(ram.dup, [1])
puts output.join(',')
puts "second puzzle:"
output = execute_program(ram.dup, [5])
puts output.join(',')

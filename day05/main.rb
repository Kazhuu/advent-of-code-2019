require 'test/unit'

extend Test::Unit::Assertions

def add_opcoce(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = get_params(ram, pointer, arg1_immediate, arg2_immediate).reduce(:+)
  4
end

def multiply_opcode(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = get_params(ram, pointer, arg1_immediate, arg2_immediate).reduce(:*)
  4
end

def input_opcode(ram, pointer, input)
  ram[ram[pointer + 1]] = input.pop
  2
end

def output_opcode(ram, pointer, output)
  output.push(ram[ram[pointer + 1]])
  2
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
    instruction_pointer += if opcode == 1
      add_opcoce(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 2
      multiply_opcode(ram, instruction_pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 3
      input_opcode(ram, instruction_pointer, input)
    elsif opcode == 4
      output_opcode(ram, instruction_pointer, output)
    else
      byebug
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

ram = File.read('input').split(',').map(&:to_i)
input = [1]

puts "first puzzle:"
output = execute_program(ram, input)
puts output.join(',')

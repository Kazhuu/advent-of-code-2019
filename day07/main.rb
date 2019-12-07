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

def execute_program(ram, input)
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

def generate_phase_permutations()
  [0, 1, 2, 3, 4].permutation.to_a
end

ram = File.read('input').split(',').map(&:to_i)
outputs = []
generate_phase_permutations.each do |phases|
  input = [0]
  phases.each do |phase|
    input.append(phase)
    input = execute_program(ram.dup, input)
  end
  outputs.append(input[0])
end
puts "First puzzle: #{outputs.max}"

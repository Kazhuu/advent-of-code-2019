class Amplifier
  attr_reader :phase
  attr_accessor :ram, :pointer, :halted, :input, :output, :phase_used

  def initialize(ram, phase)
    @ram = ram
    @phase = phase
    @pointer = 0
    @halted = false
    @input = 0
    @output = 0
    @phase_used = false
  end
end

def add_opcoce(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = get_params(ram, pointer, arg1_immediate, arg2_immediate).reduce(:+)
  pointer + 4
end

def multiply_opcode(ram, pointer, arg1_immediate, arg2_immediate)
  ram[ram[pointer + 3]] = get_params(ram, pointer, arg1_immediate, arg2_immediate).reduce(:*)
  pointer + 4
end

def input_opcode(ram, pointer, input)
  ram[ram[pointer + 1]] = input
  pointer + 2
end

def output_opcode(ram, pointer, arg1_immediate)
  param = get_param(ram, pointer + 1, arg1_immediate)
  [pointer + 2, param]
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

def execute_program(amplifier)
  while amplifier.ram[amplifier.pointer] != 99 do
    opcode, arg1_immediate, arg2_immediate = decode_opcode(amplifier.ram[amplifier.pointer])
    if opcode == 1
      amplifier.pointer = add_opcoce(amplifier.ram, amplifier.pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 2
      amplifier.pointer = multiply_opcode(amplifier.ram, amplifier.pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 3
      unless amplifier.phase_used
        amplifier.pointer = input_opcode(amplifier.ram, amplifier.pointer, amplifier.phase)
        amplifier.phase_used = true
      else
        amplifier.pointer = input_opcode(amplifier.ram, amplifier.pointer, amplifier.input)
      end
    elsif opcode == 4
      amplifier.pointer, amplifier.output = output_opcode(amplifier.ram, amplifier.pointer, arg1_immediate)
      return
    elsif opcode == 5
      amplifier.pointer = jump_if_true(amplifier.ram, amplifier.pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 6
      amplifier.pointer = jump_if_false(amplifier.ram, amplifier.pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 7
      amplifier.pointer = less_than(amplifier.ram, amplifier.pointer, arg1_immediate, arg2_immediate)
    elsif opcode == 8
      amplifier.pointer = equals(amplifier.ram, amplifier.pointer, arg1_immediate, arg2_immediate)
    else
      raise "invalid opcode"
    end
  end
  amplifier.halted = true
end

def generate_phase_permutations(range)
  range.to_a.permutation.to_a
end

ram = File.read('input').split(',').map(&:to_i)
# First puzzle.
outputs = []
generate_phase_permutations(0..4).each do |phases|
  input = 0
  phases.each do |phase|
    amplifier = Amplifier.new(ram.dup, phase)
    amplifier.input = input
    execute_program(amplifier)
    input = amplifier.output
  end
  outputs.append(input)
end
puts "First puzzle: #{outputs.max}"

# Second puzzle.
outputs = []
generate_phase_permutations(5..9).each do |phases|
  amplifiers = []
  phases.each do |phase|
    amplifiers.push(Amplifier.new(ram.dup, phase))
  end
  index = 0
  until amplifiers.last.halted do
    amplifiers[index].input = amplifiers[index - 1].output
    execute_program(amplifiers[index])
    index = (index + 1) % 5
  end
  outputs.append(amplifiers.last.output)
end
puts "Second puzzle: #{outputs.max}"

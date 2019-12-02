require 'test/unit'

extend Test::Unit::Assertions

def opcodes
  {
    1 => ->(ram, p) { ram[ram[p + 3]] = ram[ram[p + 1]] + ram[ram[p + 2]] },
    2 => ->(ram, p) { ram[ram[p + 3]] = ram[ram[p + 1]] * ram[ram[p + 2]] }
  }
end

def execute_program(ram)
  instruction_pointer = 0
  while ram[instruction_pointer] != 99 do
    opcode = ram[instruction_pointer]
    opcodes[opcode].call(ram, instruction_pointer) if opcodes.key?(opcode)
    instruction_pointer += 4
  end
  ram[0]
end

def increment_program_parameters(noun, verb)
  noun += 1
  if noun > 99
    verb += 1
    noun = 0
  end
  [noun, verb]
end

assert_equal(2, execute_program([1, 0, 0, 0, 99]))
assert_equal(2, execute_program([2, 3, 0, 3, 99]))
assert_equal(2, execute_program([2, 4, 4, 5, 99, 0]))
assert_equal(30, execute_program([1, 1, 1, 4, 99, 5, 6, 0, 99]))
assert_equal([1, 0], increment_program_parameters(0, 0))

def part_one(ram)
  # Set correct state before executing.
  ram[1] = 12
  ram[2] = 2
  puts execute_program(ram)
end

def part_two(ram)
  target = 19_690_720
  result = 0
  noun = -1
  verb = 0
  while result != target do
    noun, verb = increment_program_parameters(noun, verb)
    ram[1] = noun
    ram[2] = verb
    result = execute_program(ram.dup)
    if verb > 99
      break
    end
  end
  if result == target
    puts "target: #{result} found with noun: #{noun} and verb: #{verb}"
    puts "answer: #{100 * noun + verb}"
  else
    puts "target not found"
  end
end

ram = File.read('input').split(',').map { |value| value.to_i }
puts "first puzzle:"
part_one(ram.dup)
puts "second puzzle:"
part_two(ram.dup)

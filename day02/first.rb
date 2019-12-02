require 'test/unit'

extend Test::Unit::Assertions

def opcodes
  {
    1 => ->(ram, p) { ram[ram[p + 3]] = ram[ram[p + 1]] + ram[ram[p + 2]] },
    2 => ->(ram, p) { ram[ram[p + 3]] = ram[ram[p + 1]] * ram[ram[p + 2]] }
  }
end

def execute_program(ram)
  current_position = 0

  while ram[current_position] != 99 do
    opcode = ram[current_position]
    opcodes[opcode].call(ram, current_position) if opcodes.key?(opcode)
    current_position += 4
  end

  ram
end

assert_equal([2, 0, 0, 0, 99], execute_program([1, 0, 0, 0, 99]))
assert_equal([2, 3, 0, 6, 99], execute_program([2, 3, 0, 3, 99]))
assert_equal([2, 4, 4, 5, 99, 9801], execute_program([2, 4, 4, 5, 99, 0]))
assert_equal([30, 1, 1, 4, 2, 5, 6, 0, 99], execute_program([1, 1, 1, 4, 99, 5, 6, 0, 99]))

ram = File.read('input').split(',').map { |value| value.to_i }
# Set correct state before executing.
ram[1] = 12
ram[2] = 2

execute_program(ram)
puts ram[0]

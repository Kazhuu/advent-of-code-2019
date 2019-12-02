require 'test/unit'
require 'byebug'

extend Test::Unit::Assertions

ram = File.read('input').split(',').map(:to_i)

def opcodes
  { '1': ->(p) { ram[p + 3] = ram[p + 1] + ram[p + 2] },
    '2': ->(p) { ram[p + 3] = ram[p + 1] * ram[p + 2] }
  }
end

def execute_program(ram)
  current_position = 0

  while ram[current_position] != '99' do
    byebug
    opcode = ram[current_position].to_s
    opcodes[opcode].call(current_position) if opcodes.key?(opcode)
    current_position += 4
  end
  ram
end

assert_equal([2,0,0,0,99], execute_program([1,0,0,0,99]))


# Set program state to "1202 program alarm".
ram[1] = 12
ram[2] = 2

puts ram[0]

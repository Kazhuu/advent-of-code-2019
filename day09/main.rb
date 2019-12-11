require 'test/unit'

extend Test::Unit::Assertions

class IntCore
  attr_accessor :ram, :pointer, :relative_base, :halted, :input, :output

  def initialize(ram)
    @ram = Hash.new(0)
    ram.each_with_index do |value, index|
      @ram[index] = value
    end
    @pointer = 0
    @relative_base = 0
    @halted = false
    @input = []
    @output = []
  end

  def execute(until_end = true)
    while @ram[@pointer] != 99 do
      opcode, modes = decode_opcode
      if opcode == 1
        add_opcoce(modes)
      elsif opcode == 2
        multiply_opcode(modes)
      elsif opcode == 3
        input_opcode(modes[0])
      elsif opcode == 4
        output_opcode(modes[0])
        return unless until_end
      elsif opcode == 5
        jump_if_true(modes)
      elsif opcode == 6
        jump_if_false(modes)
      elsif opcode == 7
        less_than(modes)
      elsif opcode == 8
        equals(modes)
      elsif opcode == 9
        modify_relative_offset(modes[0])
      else
        raise "invalid opcode"
      end
    end
    @halted = true
  end

  def add_opcoce(modes)
    result = get_params(modes).reduce(:+)
    write_value(@ram[@pointer + 3], modes[2], result)
    @pointer += 4
  end

  def multiply_opcode(modes)
    result = get_params(modes).reduce(:*)
    write_value(@ram[@pointer + 3], modes[2], result)
    @pointer += 4
  end

  def input_opcode(mode)
    write_value(@ram[@pointer + 1], mode, @input.pop)
    @pointer += 2
  end

  def output_opcode(mode)
    param = get_param(pointer + 1, mode)
    @pointer += 2
    @output.append(param)
  end

  def jump_if_true(modes)
    first, second = get_params(modes)
    unless first.zero?
      @pointer = second
    else
      @pointer += 3
    end
  end

  def jump_if_false(modes)
    first, second = get_params(modes)
    if first.zero?
      @pointer = second
    else
      @pointer += 3
    end
  end

  def modify_relative_offset(mode)
    @relative_base += get_param(@pointer + 1, mode)
    @pointer += 2
  end

  def less_than(modes)
    first, second = get_params(modes)
    result = if first < second
               1
             else
               0
             end
    write_value(@ram[@pointer + 3], modes[2], result)
    @pointer += 4
  end

  def equals(modes)
    first, second = get_params(modes)
    result = if first == second
               1
             else
               0
             end
    write_value(@ram[@pointer + 3], modes[2], result)
    @pointer += 4
  end

  def get_params(modes)
    [get_param(@pointer + 1, modes[0]), get_param(@pointer + 2, modes[1])]
  end

  def get_param(pointer, mode)
    if mode == 0
      @ram[@ram[pointer]]
    elsif mode == 1
      @ram[pointer]
    elsif mode == 2
      @ram[@relative_base + @ram[pointer]]
    else
      raise "unknown mode"
    end
  end

  def write_value(pointer, mode, value)
    if mode == 0
      @ram[pointer] = value
    elsif mode == 2
      @ram[pointer + @relative_base] = value
    else
      raise "invalid write mode"
    end
  end

  def decode_opcode
    opcode = '%05d' % @ram[@pointer]
    [opcode[3..].to_i, [opcode[2].to_i, opcode[1].to_i, opcode[0].to_i]]
  end
end

program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
test = IntCore.new(program)
test.execute
assert_equal(program, test.output)
test = IntCore.new([1102,34915192,34915192,7,4,7,99,0])
test.execute
assert_equal([1219070632396864], test.output)
test = IntCore.new([104,1125899906842624,99])
test.execute
assert_equal([1125899906842624], test.output)

# First puzzle.
ram = File.read('input').split(',').map(&:to_i)
program = IntCore.new(ram.dup)
program.input = [1]
program.execute
puts "First puzzle: #{program.output.first}"

# Second puzzle.
program = IntCore.new(ram.dup)
program.input = [2]
program.execute
puts "Second puzzle: #{program.output.first}"

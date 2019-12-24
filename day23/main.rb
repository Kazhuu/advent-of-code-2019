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

  def step()
    return if @halted
    opcode, modes = decode_opcode
    if opcode == 1
      add_opcoce(modes)
    elsif opcode == 2
      multiply_opcode(modes)
    elsif opcode == 3
      input_opcode(modes[0])
    elsif opcode == 4
      output_opcode(modes[0])
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
    elsif opcode == 99
      @halted = true
    else
      raise "invalid opcode"
    end
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
    input = @input.shift || -1
    write_value(@ram[@pointer + 1], mode, input)
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

ram = File.read('input').split(',').map(&:to_i)
computers = []
addresses = Hash.new([])
(0...50).each do |address|
  computer = IntCore.new(ram.dup)
  computer.input.append(address)
  computers.push(computer)
end
until addresses[255].count == 2 do
  computers.each do |computer|
    computer.step
  end
  computers.each do |computer|
    if computer.output.count == 3
      packet = computer.output
      address = packet[0]
      data = packet[1..]
      computer.output = []
      if address > 50
        addresses[address] = data
      else
        computers[address].input.append(*data)
      end
    end
  end
end
puts "First puzzle: #{addresses[255][1]}"

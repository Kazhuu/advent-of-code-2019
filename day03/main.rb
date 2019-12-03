require 'test/unit'
require 'set'

extend Test::Unit::Assertions

def line_to_set(wire_information)
  x = 0
  y = 0
  wire = Set.new
  wire_information.each do |information|
    direction, distance = parse_distance_and_direction(information)
    distance.times do |i|
      if direction == 'D'
        y -= 1
      elsif direction == 'U'
        y += 1
      elsif direction == 'L'
        x -= 1
      elsif direction == 'R'
        x += 1
      else
        raise "invalid direction"
      end
      wire.add([x, y])
    end
  end
  wire
end

def parse_distance_and_direction(information)
  direction, distance = information.scan(/^([LRUD])(\d+)$/).first
  [direction, distance.to_i]
end

def manhattan_distance(x, y)
  x.abs + y.abs
end

def min_manhattan_distance(intersections)
  manhattan_distances = intersections.to_a.map { |point| manhattan_distance(*point) }
  manhattan_distances.min
end

def wire_intersection_lengths(intersections, wire_information)
  x = 0
  y = 0
  length = 0
  lengths = {}
  wire_information.each do |information|
    direction, distance = parse_distance_and_direction(information)
    distance.times do |i|
      if direction == 'D'
        y -= 1
      elsif direction == 'U'
        y += 1
      elsif direction == 'L'
        x -= 1
      elsif direction == 'R'
        x += 1
      else
        raise "invalid direction"
      end
      length += 1
      point = [x, y]
      lengths[point] = length if intersections.include?(point)
    end
  end
  lengths
end

def min_intersection_length(intersections, wire1_lengths, wire2_lengths)
  distances = []
  intersections.each do |point|
    distances.push(wire1_lengths[point] + wire2_lengths[point])
  end
  distances.min
end

# Test methods.
assert_equal(['L', 5], parse_distance_and_direction('L5'))
assert_equal(['R', 755], parse_distance_and_direction('R755'))
assert_equal([[1, 0], [1, 1], [1, 2]].to_set, line_to_set(['R1', 'U2']))
# Test example from the first part.
test_wire1 = line_to_set(['R75','D30','R83','U83','L12','D49','R71','U7','L72'])
test_wire2 = line_to_set(['U62','R66','U55','R34','D71','R55','D58','R83'])
intersections = test_wire1 & test_wire2
assert_equal(159, min_manhattan_distance(intersections))
# Test exmple second part of the puzzle.
test_wire1_lengths = wire_intersection_lengths(intersections, ['R75','D30','R83','U83','L12','D49','R71','U7','L72'])
test_wire2_lengths = wire_intersection_lengths(intersections, ['U62','R66','U55','R34','D71','R55','D58','R83'])
assert_equal(610, min_intersection_length(intersections, test_wire1_lengths, test_wire2_lengths))

# Actual puzzle.
lines = File.readlines('input')
line1_information = lines[0].split(',')
line2_information = lines[1].split(',')

# First puzzle.
wire1 = line_to_set(line1_information)
wire2 = line_to_set(line2_information)
intersections = wire1 & wire2
puts min_manhattan_distance(intersections)

# Second puzzle.
wire1_lengths = wire_intersection_lengths(intersections, line1_information)
wire2_lengths = wire_intersection_lengths(intersections, line2_information)
puts min_intersection_length(intersections, wire1_lengths, wire2_lengths)

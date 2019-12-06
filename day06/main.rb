require 'test/unit'

extend Test::Unit::Assertions

class Node
  attr_reader :name
  attr_accessor :depth
  attr_accessor :children

  def initialize(name)
    @name = name
    @children = []
  end
end

def parse_orbit_map(input)
  next_search = 'COM'
  objects = {}
  objects[next_search] = Node.new(next_search)
  input.each do |line|
    first, second = line.split(')')
    first_node = if objects.key?(first)
                   objects[first]
                 else
                   Node.new(first)
                 end
    second_node = if objects.key?(second)
                   objects[second]
                 else
                   Node.new(second)
                 end
    first_node.children.push(second_node)
    objects[first] = first_node
    objects[second] = second_node
    puts first
  end
  objects
end

def calculate_depth(node, depth)
  node.depth = depth
  node.children.each do |child|
    calculate_depth(child, depth + 1)
  end
end

orbits = File.readlines('input').map(&:strip)
objects = parse_orbit_map(orbits)
calculate_depth(objects['COM'], 0)

checksum = 0
objects.each do |_key, value|
  checksum += value.depth
end
puts checksum

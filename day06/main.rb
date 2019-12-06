class Node
  attr_reader :name
  attr_accessor :parent, :depth, :children

  def initialize(name)
    @name = name
    @children = []
    @parent = nil
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
    second_node.parent = first_node
    objects[first] = first_node
    objects[second] = second_node
  end
  objects
end

def calculate_depth(node, depth)
  node.depth = depth
  node.children.each do |child|
    calculate_depth(child, depth + 1)
  end
end

def path_to_node(node)
  path = []
  while not node.parent.nil? do
    path.append(node.parent)
    node = node.parent
  end
  path
end

orbits = File.readlines('input').map(&:strip)
objects = parse_orbit_map(orbits)
calculate_depth(objects['COM'], 0)

# First puzzle.
checksum = 0
objects.each do |_key, value|
  checksum += value.depth
end
puts "First puzzle: #{checksum}"

# Second puzzle.
path_to_you = path_to_node(objects['YOU'])
path_to_san = path_to_node(objects['SAN'])
common_nodes = path_to_you & path_to_san
steps = (path_to_san - common_nodes).count + (path_to_you - common_nodes).count
puts "Second puzzle: #{steps}"

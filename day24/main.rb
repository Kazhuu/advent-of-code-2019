def advance(map)
  new_map = map.dup
  (0..4).each do |y|
    (0..4).each do |x|
      char = map[[x, y]]
      if char == '#'
        dies(x, y, map, new_map)
      else
        infested(x, y, map, new_map)
      end
    end
  end
  new_map
end

def infested(x, y, map, new_map)
  count = adjacent_bugs(x, y, map)
  new_map[[x, y]] = if count == 1 or count == 2
                      '#'
                    else
                      '.'
                    end
end

def dies(x, y, map, new_map)
  count = adjacent_bugs(x, y, map)
  new_map[[x, y]] = if count == 1
                      '#'
                    else
                      '.'
                    end
end

def adjacent_bugs(x, y, map)
  bugs = []
  bugs.append(map[[x, y - 1]])
  bugs.append(map[[x, y + 1]])
  bugs.append(map[[x - 1, y]])
  bugs.append(map[[x + 1, y]])
  bugs.count('#')
end

def draw_map(map)
  (0..4).each do |y|
    line = []
    (0..4).each do |x|
      line.append(map[[x, y]])
    end
    puts line.join
  end
end

def calculate_biodiversity(map)
  total = 0
  (0..4).each do |y|
    (0..4).each do |x|
      total += 2**(5 * y + x) if map[[x, y]] == '#'
    end
  end
  total
end

lines = File.readlines('input')
map = Hash.new('.')
lines.each_with_index do |line, y|
  line.strip.split('').each_with_index do |char, x|
    map[[x, y]] = char
  end
end

biodiversities = Hash.new(0)
biodiversities[calculate_biodiversity(map)] += 1
until biodiversities.has_value?(2) do
  map = advance(map)
  biodiversities[calculate_biodiversity(map)] += 1
end

puts "First puzzle: #{biodiversities.key(2)}"

require 'test/unit'

extend Test::Unit::Assertions

def count_detected_asteroids(station, asteroids)
  results = []
  asteroids.each do |x, y|
    dx = x - station[0]
    dy = y - station[1]
    divisor = dx.gcd(dy)
    results.append([dx / divisor, dy / divisor])
  end
  results.uniq.count
end

def best_location_for_station(map)
  asteroids = []
  map.each_with_index do |line, y|
    line.split('').each_with_index do |mark, x|
      asteroids.append([x, y]) if mark == '#'
    end
  end

  detect_counts = []
  asteroids.each do |station|
    detect_counts.append(count_detected_asteroids(station, asteroids - [station]))
  end
  detect_counts.max
end

map = [".#..#", ".....", "#####", "....#", "...##"]
assert_equal(8, best_location_for_station(map))

map = File.readlines('input')
result = best_location_for_station(map)
puts "First puzzle: #{result}"


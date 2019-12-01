require 'test/unit'

extend Test::Unit::Assertions

def fuel_needed(mass)
  total = 0
  while mass > 0 do
    mass = mass / 3 - 2
    total += mass if mass > 0
  end
  total
end

assert_equal(2, fuel_needed(14))
assert_equal(966, fuel_needed(1969))
assert_equal(50346, fuel_needed(100756))

module_masses = File.readlines('input')
puts module_masses.reduce(0) { |total, mass| total += fuel_needed(mass.to_i) }

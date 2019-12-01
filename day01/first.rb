module_masses = File.readlines('input')
puts module_masses.reduce(0) { |total, mass| total += mass.to_i / 3 - 2 }


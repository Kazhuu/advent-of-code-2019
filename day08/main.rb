class Layer
  attr_reader :data

  def initialize(heigth, width, data)
    @data = data.slice!(0, heigth * width)
  end

  def count_digits(digit)
    @data.count(digit)
  end
end

def layer_with_fewest_zeros(layers)
  counts = layers.map { |layer| layer.count_digits(0) }
  layers[counts.each_with_index.min.last]
end

def decode_image(height, width, layers)
  result = [[]]
  (0..height-1).each do |y|
    (0..width-1).each do |x|
      layers.each do |layer|
        pixel_index = y * width + x
        if layer.data[pixel_index] != 2
          result[y] = [] if result[y].nil?
          result[y][x] = layer.data[pixel_index]
          break
        end
      end
    end
  end
  result
end

heigth = 6
width = 25
layers = []
data = File.read('input').split('').map(&:to_i)

# First puzzle.
until data.empty? do
  layers.append(Layer.new(heigth, width, data))
end
layer = layer_with_fewest_zeros(layers[0..-2])
puts "First answer: #{layer.count_digits(1) * layer.count_digits(2)}"

# Second puzzle.
puts "Second answer:"
result = decode_image(heigth, width, layers[0..-2])
result.each do |line|
  line = line.map { |char| char.zero? ? ' ' : '#' }
  puts line.join('')
end

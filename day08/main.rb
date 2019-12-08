class Layer
  attr_reader :data, :height, :width

  def initialize(heigth, width, data)
    @heigth = heigth
    @width = width
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

width = 25
heigth = 6
layers = []
data = File.read('input').split('').map(&:to_i)
until data.empty? do
  layers.append(Layer.new(heigth, width, data))
end
layer = layer_with_fewest_zeros(layers[0..-2])
puts "First answer: #{layer.count_digits(1) * layer.count_digits(2)}"


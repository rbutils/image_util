module ImageUtil
  module View
    # Has overriden methods: [] and []= that allow subpixel
    # arguments. This will allow for antialiasing, drawing
    # graphs, etc.
    Subpixel = Data.define(:image) do
      def generate_subpixel_hash(location)
        array = location.map do |i|
          if i % 1 == 0
            [[i.floor, 1]]
          else
            [[i.floor, i % 1], [i.floor + 1, 1 - i % 1]]
          end
        end

        hash = {}
        array.shift.product(*array) do |combination|
          loc, weight = combination.transpose
          hash[loc] = weight.reduce(:*)
        end
        hash
      end

      def [](*location)
        generate_subpixel_hash(location).map do |loc, weight|
          image[*loc].map { |i| i * weight }
        end.reduce([]) do |accum, color|
          color.zip(accum).map { |c,a| a + (c || 0) }
        end.then { |a| Color.new(*a) }
      end

      def []=(*location, value)
        value = Color[value]

        generate_subpixel_hash(location).each do |loc, weight|
          image[*loc] += value * weight
        end
      end
    end
  end
end 

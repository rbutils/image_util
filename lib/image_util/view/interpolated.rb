# frozen_string_literal: true

module ImageUtil
  module View
    # Allows fractional coordinates by distributing values to
    # neighbouring pixels using bilinear interpolation.
    Interpolated = Data.define(:image) do
      def generate_subpixel_hash(location)
        arrays = location.map do |i|
          frac = i % 1
          if frac.zero?
            [[i.floor, 1.0]]
          else
            [[i.floor, 1 - frac], [i.floor + 1, frac]]
          end
        end

        hash = {}
        arrays.shift.product(*arrays) do |combination|
          loc, weight = combination.transpose
          hash[loc] = weight.reduce(:*)
        end
        hash
      end

      def [](*location)
        accum = Array.new(image.channels, 0.0)
        generate_subpixel_hash(location).each do |loc, weight|
          image[*loc].each_with_index do |val, idx|
            accum[idx] += val * weight
          end
        end
        Color.new(*accum)
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

module ImageUtil
  module Converter
    class Sixel
      MAX_COLORS = 256

      def self.convert(image)
        new(image).convert
      end

      def initialize(image)
        @image = image
      end

      def convert
        check_dimensions
        build_palette
        encode
      end

      private

      def check_dimensions
        if @image.dimensions.length > 2
          raise ArgumentError, "only 1D or 2D images are supported"
        end
      end

      def width  = @image.width
      def height = @image.height || 1

      def build_palette
        histogram = Hash.new(0)
        pixels    = Array.new(height) { Array.new(width) }

        @image.each_pixel_location do |loc|
          color = @image[*loc]
          rgba  = if color.a < 128
                    [0, 0, 0, 0]
                  else
                    [color.r, color.g, color.b, 255]
                  end
          histogram[rgba] += 1
          x = loc[0]
          y = loc[1] || 0
          pixels[y][x] = rgba
        end

        reduce_palette(histogram)

        @palette = [[0, 0, 0, 0]] + histogram.keys
        @map     = {}
        @palette.each_with_index { |c, i| @map[c] = i }
        @index = Array.new(height) { Array.new(width, 0) }

        pixels.each_with_index do |row, y|
          row.each_with_index do |rgba, x|
            @index[y][x] = find_closest_index(rgba)
          end
        end
      end

      def reduce_palette(hist)
        while hist.length > MAX_COLORS - 1
          pair = hist.keys.combination(2).min_by do |a, b|
            freq = [hist[a], hist[b]].min
            distance(a, b) * freq
          end
          a, b = pair
          fa = hist.delete(a)
          fb = hist.delete(b)
          total = fa + fb
          new_color = [
            (a[0] * fa + b[0] * fb) / total,
            (a[1] * fa + b[1] * fb) / total,
            (a[2] * fa + b[2] * fb) / total,
            (a[3] * fa + b[3] * fb) / total
          ].map(&:round)
          hist[new_color] += total
        end
      end

      def distance(a, b)
        (a[0] - b[0])**2 +
        (a[1] - b[1])**2 +
        (a[2] - b[2])**2 +
        (a[3] - b[3])**2
      end



      def find_closest_index(rgba)
        min_idx = 0
        min_dist = Float::INFINITY
        @palette.each_with_index do |c, idx|
          dist = (c[0] - rgba[0])**2 +
                 (c[1] - rgba[1])**2 +
                 (c[2] - rgba[2])**2 +
                 (c[3] - rgba[3])**2
          if dist < min_dist
            min_dist = dist
            min_idx = idx
          end
        end
        min_idx
      end

      def encode
        sixel = "\ePq\"1;1;1;1"
        encode_palette(sixel)
        encode_pixels(sixel)
        sixel << "\e\\"
      end

      def encode_palette(sixel)
        @palette.each_with_index do |(r, g, b, a), idx|
          args = [percent(r), percent(g), percent(b)].join(";")
          args += ";4" if a < 255
          sixel << "##{idx};2;#{args}"
        end
      end

      def encode_pixels(sixel)
        (0...height).step(6) do |y0|
          @palette.each_index do |idx|
            sixel << "##{idx}"
            width.times do |x|
              bits = 0
              0.upto(5) do |dy|
                y = y0 + dy
                bits |= 1 << dy if y < height && @index[y][x] == idx
              end
              sixel << (63 + bits).chr
            end
            sixel << "$"
          end
          sixel.chop!
          sixel << "-"
        end
        sixel.chop!
      end

      def percent(val)
        (val * 100 / 255.0).round
      end
    end
  end
end

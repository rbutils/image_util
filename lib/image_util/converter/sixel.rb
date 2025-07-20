module ImageUtil
  module Converter
    class Sixel
      MAX_COLORS = 255

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
        @palette = [[0, 0, 0, 0]]
        @map     = { [0, 0, 0, 0] => 0 }
        @index   = Array.new(height) { Array.new(width, 0) }

        @image.each_pixel_location do |loc|
          color = @image[*loc]
          rgba  = [color.r, color.g, color.b, color.a]
          qrgba = quantize(rgba)
          idx   = map_color(qrgba)
          x     = loc[0]
          y     = loc[1] || 0
          @index[y][x] = idx
        end

        # palette size is implicitly limited by quantization
      end

      def map_color(rgba)
        unless @map.key?(rgba)
          if @palette.length <= MAX_COLORS
            @map[rgba] = @palette.length
            @palette << rgba
          else
            @map[rgba] = find_closest_index(rgba)
          end
        end
        @map[rgba]
      end

      def quantize(rgba)
        r, g, b, a = rgba
        r = ((r.to_f / 51).round * 51).clamp(0, 255)
        g = ((g.to_f / 51).round * 51).clamp(0, 255)
        b = ((b.to_f / 51).round * 51).clamp(0, 255)
        a = a < 128 ? 0 : 255
        [r, g, b, a]
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

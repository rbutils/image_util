module ImageUtil
  module Converter
    class Sixel
      def self.convert(image)
        new(image).convert
      end

      def initialize(image)
        @image = image
      end

      def convert
        raise ArgumentError, "only 1D or 2D images are supported" if @image.dimensions.length > 2

        width  = @image.width
        height = @image.height || 1

        palette = []
        map = {}
        pixel_index = Array.new(height) { Array.new(width) }

        @image.each_pixel_location do |loc|
          color = @image[*loc]
          rgb = [color.r, color.g, color.b]
          idx = map[rgb]
          unless idx
            idx = palette.length
            palette << rgb
            map[rgb] = idx
          end
          x = loc[0]
          y = loc[1] || 0
          pixel_index[y][x] = idx
        end

        sixel = "\ePq"
        palette.each_with_index do |(r,g,b), idx|
          sixel << "##{idx};2;#{(r * 100 / 255.0).round};#{(g * 100 / 255.0).round};#{(b * 100 / 255.0).round}"
        end

        (0...height).step(6) do |y0|
          palette.each_index do |idx|
            sixel << "##{idx}"
            width.times do |x|
              bits = 0
              0.upto(5) do |dy|
                y = y0 + dy
                next if y >= height
                bits |= 1 << dy if pixel_index[y][x] == idx
              end
              sixel << (63 + bits).chr
            end
            sixel << "$"
          end
          sixel.chop!
          sixel << "-"
        end

        sixel.chop!
        sixel << "\e\\"
      end
    end
  end
end

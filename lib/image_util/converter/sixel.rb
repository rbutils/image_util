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
        @coarse_map = nil

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

        if histogram.length > 4096
          coarse_hist = Hash.new(0)
          @coarse_map = {}
          histogram.each do |color, count|
            r, g, b, a = color
            key = [r & 0xF0, g & 0xF0, b & 0xF0, a]
            coarse_hist[key] += count
            @coarse_map[color] = key
          end
          histogram = coarse_hist
          pixels.each_with_index do |row, y|
            row.each_with_index do |rgba, x|
              pixels[y][x] = @coarse_map[rgba]
            end
          end
        end

        @quantize = histogram.length > MAX_COLORS - 1

        if @quantize
          histogram, @bin_map = quantize_histogram(histogram)
        end

        @palette = [[0, 0, 0, 0]] + histogram.keys
        @map     = {}
        @palette.each_with_index { |c, i| @map[c] = i }
        @index = Array.new(height) { Array.new(width, 0) }

        pixels.each_with_index do |row, y|
          row.each_with_index do |rgba, x|
            @index[y][x] = locate_index(rgba)
          end
        end
      end

      def quantize_histogram(hist)
        sorted = hist.sort_by { |_, count| -count }
        keep = sorted.take(MAX_COLORS - 1)

        bin_map = {}
        palette_colors = keep.map(&:first)
        keep.each { |color, _| bin_map[color] = color }

        sorted.drop(MAX_COLORS - 1).each do |color, _|
          nearest = palette_colors.min_by { |c| dist(c, color) }
          bin_map[color] = nearest
        end

        [keep.to_h, bin_map]
      end

      def dist(c1, c2)
        (c1[0] - c2[0])**2 + (c1[1] - c2[1])**2 + (c1[2] - c2[2])**2
      end

      def locate_index(rgba)
        return 0 if rgba[3] == 0
        color = @coarse_map ? @coarse_map[rgba] : rgba
        if @quantize
          pal_color = @bin_map[color]
          @map[pal_color]
        else
          @map[color]
        end
      end

      def encode
        sixel = "\ePq\"1;1;1;1"
        encode_palette(sixel)
        encode_pixels(sixel)
        sixel << "\e\\"
      end

      def encode_palette(sixel)
        @palette.each_with_index do |(r, g, b, _a), idx|
          args = [percent(r), percent(g), percent(b)].join(";")
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

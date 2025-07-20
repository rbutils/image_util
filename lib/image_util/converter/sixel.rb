module ImageUtil
  module Converter
    class Sixel
      MAX_COLORS = 256
      QUANT      = 6

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
        bins = Hash.new { |h,k| h[k] = [0,0,0,0] } # rsum, gsum, bsum, count
        hist.each do |rgba, count|
          next if rgba[3] == 0
          key = quant_key(rgba)
          bin = bins[key]
          bin[0] += rgba[0] * count
          bin[1] += rgba[1] * count
          bin[2] += rgba[2] * count
          bin[3] += count
        end

        quant_hist = {}
        bin_map = {}
        bins.each do |key, vals|
          r = (vals[0] / vals[3].to_f).round
          g = (vals[1] / vals[3].to_f).round
          b = (vals[2] / vals[3].to_f).round
          color = [r, g, b, 255]
          quant_hist[color] = vals[3]
          bin_map[key] = color
        end

        [quant_hist, bin_map]
      end

      def quant_key(rgba)
        [
          rgba[0] * (QUANT - 1) / 255,
          rgba[1] * (QUANT - 1) / 255,
          rgba[2] * (QUANT - 1) / 255
        ]
      end

      def locate_index(rgba)
        return 0 if rgba[3] == 0
        if @quantize
          key = quant_key(rgba)
          pal_color = @bin_map[key]
          @map[pal_color]
        else
          @map[rgba]
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

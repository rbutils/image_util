# frozen_string_literal: true

module ImageUtil
  module Codec
    module RubySixel
      SUPPORTED_FORMATS = [:sixel].freeze

      module_function

      def supported?(format = nil)
        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        unless SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
          raise UnsupportedFormatError, "unsupported format #{format}"
        end
        unless image.dimensions.length == 2
          raise ArgumentError, "only 2D images supported"
        end

        unless image.color_bits == 8
          raise ArgumentError, "only 8-bit colors supported"
        end

        img = if image.unique_color_count <= 256
                image
              else
                image.dither(256)
              end

        palette = []
        palette_map = {}
        img.each_pixel do |color|
          key = color.to_a
          next if palette_map.key?(key)

          palette_map[key] = palette.length
          palette << color
        end

        out = "\ePq".dup
        palette.each_with_index do |c, idx|
          out << format("#%d;2;%d;%d;%d", idx, c.r * 100 / 255, c.g * 100 / 255, c.b * 100 / 255)
        end

        height = img.height || 1
        width = img.width || 1

        (0...height).step(6) do |y|
          palette.each_with_index do |_c, idx|
            out << "##{idx}"
            run_char = nil
            run_len = 0
            (0...width).each do |x|
              bits = 0
              6.times do |i|
                yy = y + i
                if yy < height && palette_map[img[x, yy].to_a] == idx
                  bits |= 1 << i
                end
              end
              char = (63 + bits).chr
              if char == run_char
                run_len += 1
              else
                out << "!#{run_len}" << run_char if run_len > 1
                out << run_char if run_len == 1
                run_char = char
                run_len = 1
              end
            end
            out << "!#{run_len}" << run_char if run_len > 1
            out << run_char if run_len == 1
            out << "$"
          end
          out << "-"
        end

        out << "\e\\"
        out
      end

      def encode_io(format, image, io)
        io << encode(format, image)
      end

      def decode(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end

      def decode_io(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end
    end
  end
end

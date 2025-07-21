# frozen_string_literal: true

module ImageUtil
  module Codec
    module RubySixel
      SUPPORTED_FORMATS = [:sixel].freeze
      CHAR_MAP = (0..63).map { |b| (63 + b).chr }.freeze

      extend Guard

      module_function

      def supported?(format = nil)
        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        guard_2d_image!(image)
        guard_8bit_colors!(image)

        img = if image.unique_color_count <= 256
                image
              else
                image.dither(256)
              end

        height = img.height || 1
        width = img.width || 1

        palette = []
        palette_map = {}
        idx_image = Array.new(height * width)
        buf = img.buffer
        idx = 0
        step = buf.pixel_bytes

        height.times do |y|
          row = y * width
          width.times do |x|
            color = buf.get_index(idx)
            key = (color[0] || 255) |
                  ((color[1] || 255) << 8) |
                  ((color[2] || 255) << 16) |
                  ((color[3] || 255) << 24)
            pal_idx = palette_map[key]
            unless pal_idx
              pal_idx = palette.length
              palette_map[key] = pal_idx
              palette << color
            end
            idx_image[row + x] = pal_idx
            idx += step
          end
        end

        out = "\ePq".dup
        palette.each_with_index do |c, idx|
          out << format("#%d;2;%d;%d;%d", idx, c.r * 100 / 255, c.g * 100 / 255, c.b * 100 / 255)
        end

        (0...height).step(6) do |y|
          palette.each_index do |idx|
            out << "##{idx}"
            run_char = nil
            run_len = 0
            x = 0
            while x < width
              bits = 0
              yy = y
              i = 0
              while i < 6
                if yy < height && idx_image[yy * width + x] == idx
                  bits |= 1 << i
                end
                yy += 1
                i += 1
              end
              char = CHAR_MAP[bits]
              if char == run_char
                run_len += 1
              else
                out << "!#{run_len}" << run_char if run_len > 1
                out << run_char if run_len == 1
                run_char = char
                run_len = 1
              end
              x += 1
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

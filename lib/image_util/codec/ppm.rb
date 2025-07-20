# frozen_string_literal: true

require "stringio"

module ImageUtil
  module Codec
    module Ppm
      SUPPORTED_FORMATS = [:ppm].freeze

      module_function

      def supported?(format = nil)
        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image, background: Color[:black])
        unless SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
          raise UnsupportedFormatError, "unsupported format #{format}"
        end

        unless image.dimensions.length == 2
          raise ArgumentError, "only 2D images supported"
        end

        unless image.color_bits == 8
          raise ArgumentError, "only 8-bit colors supported"
        end

        unless [3, 4].include?(image.color_length)
          raise ArgumentError, "only RGB/RGBA images supported"
        end

        img = image.background(background)

        width = img.width || 1
        height = img.height || 1
        header = "P6\n#{width} #{height}\n255\n".b

        raw = img.buffer.get_string
        if img.color_length == 4
          data = "".b
          pixel_bytes = 4
          total = width * height
          total.times do |i|
            offset = i * pixel_bytes
            data << raw.getbyte(offset).chr
            data << raw.getbyte(offset + 1).chr
            data << raw.getbyte(offset + 2).chr
          end
        else
          data = raw
        end

        header + data
      end

      def encode_io(format, image, io, **kwargs)
        io << encode(format, image, **kwargs)
      end

      def decode(format, data)
        unless SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
          raise UnsupportedFormatError, "unsupported format #{format}"
        end

        io = StringIO.new(data)
        magic = io.gets&.chomp
        raise ArgumentError, "bad magic" unless magic == "P6"

        tokens = []
        until tokens.length >= 3
          line = io.gets
          raise ArgumentError, "truncated header" unless line

          line = line.sub(/#.*/, "").strip
          next if line.empty?

          tokens.concat(line.split)
        end
        width = tokens[0].to_i
        height = tokens[1].to_i
        maxval = tokens[2].to_i
        raise ArgumentError, "only 8-bit colors supported" unless maxval == 255

        raw = io.read
        buf = IO::Buffer.for(raw)
        image_buf = Image::Buffer.new([width, height], 8, 3, buf)
        Image.from_buffer(image_buf)
      end

      def decode_io(format, io, **kwargs)
        decode(format, io.read, **kwargs)
      end
    end
  end
end

# frozen_string_literal: true

require "stringio"

module ImageUtil
  module Codec
    module Pam
      SUPPORTED_FORMATS = [:pam].freeze

      extend Guard

      module_function

      def supported?(format = nil)
        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        unless image.dimensions.length <= 2
          raise ArgumentError, "can't convert to PAM more than 2 dimensions"
        end

        unless [3, 4].include?(image.channels)
          raise ArgumentError, "can't convert to PAM if color length isn't 3 or 4"
        end

        height = image.height || 1

        header = <<~PAM.b
          P7
          WIDTH #{image.width}
          HEIGHT #{height}
          DEPTH #{image.channels}
          MAXVAL #{2**image.color_bits - 1}
          TUPLTYPE #{image.channels == 3 ? "RGB" : "RGB_ALPHA"}
          ENDHDR
        PAM

        header + image.buffer.get_string
      end

      def decode(format, data)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        decode_io(format, StringIO.new(data))
      end

      def decode_io(format, io)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        decode_frame(io)
      end

      def decode_frame(io)
        header = {}
        line = io.gets
        return nil unless line && line.delete("\r\n\0") == "P7"

        line = io.gets
        return nil unless line

        until line.delete("\r\n\0") == "ENDHDR"
          clean = line.delete("\r\n\0")
          key, val = clean.split(" ", 2)
          header[key] = val
          line = io.gets
          return nil unless line
        end

        width = header["WIDTH"].to_i
        height = header["HEIGHT"].to_i
        depth = header["DEPTH"].to_i
        maxval = header["MAXVAL"].to_i
        color_bits = Math.log2(maxval + 1).to_i
        bytes = width * height * depth * (color_bits / 8)
        raw = io.read(bytes)
        return nil unless raw && raw.bytesize == bytes

        io_buf = IO::Buffer.for(raw)
        buf = Image::Buffer.new([width, height], color_bits, depth, io_buf)
        Image.from_buffer(buf)
      end
    end
  end
end

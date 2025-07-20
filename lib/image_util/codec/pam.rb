require "stringio"

module ImageUtil
  module Codec
    module Pam
      module_function

      def encode(image, fill_to: nil)
        unless image.dimensions.length <= 2
          raise ArgumentError, "can't convert to PAM more than 2 dimensions"
        end

        unless [3, 4].include?(image.color_length)
          raise ArgumentError, "can't convert to PAM if color length isn't 3 or 4"
        end

        fill_height = image.height || 1
        fill_buffer = "".b
        if fill_to
          remaining = fill_height % fill_to
          added = remaining.zero? ? 0 : fill_to - remaining
          fill_height += added
          fill_buffer = "\0".b * added * image.pixel_bytes * image.width
        end

        header = <<~PAM.b
          P7
          WIDTH #{image.width}
          HEIGHT #{fill_height}
          DEPTH #{image.color_length}
          MAXVAL #{image.color_bits**2 - 1}
          TUPLTYPE #{image.color_length == 3 ? "RGB" : "RGB_ALPHA"}
          ENDHDR
        PAM

        header + image.buffer.get_string + fill_buffer
      end

      def encode_io(image, io, **kwargs)
        io << encode(image, **kwargs)
      end

      def decode(data)
        decode_io(StringIO.new(data))
      end

      def decode_io(io)
        header = {}
        while (line = io.gets)
          line = line.chomp
          break if line == "ENDHDR"

          key, val = line.split(" ", 2)
          header[key] = val
        end
        width = header["WIDTH"].to_i
        height = header["HEIGHT"].to_i
        depth = header["DEPTH"].to_i
        maxval = header["MAXVAL"].to_i
        color_bits = Math.log2(maxval + 1).to_i
        raw = io.read
        io_buf = IO::Buffer.for(raw)
        buf = Image::Buffer.new([width, height], color_bits, depth, io_buf)
        Image.from_buffer(buf)
      end

      Codec.register(:pam, self)
    end
  end
end

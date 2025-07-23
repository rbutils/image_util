# frozen_string_literal: true

module ImageUtil
  module Codec
    module ImageMagick
      SUPPORTED_FORMATS = %i[sixel jpeg png gif apng].freeze

      extend Guard

      module_function

      def magick_available?
        return @magick_available unless @magick_available.nil?

        @magick_available = system("magick", "-version", out: File::NULL, err: File::NULL)
      end

      def supported?(format = nil)
        return false unless magick_available?

        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        fmt = format.to_s.downcase

        if image.dimensions.length <= 2 || fmt == "sixel"
          pam = Codec::Pam.encode(:pam, image, fill_to: fmt == "sixel" ? 6 : nil)

          IO.popen(["magick", "pam:-", "#{fmt}:-"], "r+") do |proc_io|
            proc_io << pam
            proc_io.close_write
            proc_io.read
          end
        else
          frames = image.buffer.last_dimension_split.map { |b| Image.from_buffer(b) }
          stream = frames.map { |f| Codec::Pam.encode(:pam, f) }.join
          IO.popen(["magick", "pam:-", "#{fmt}:-"], "r+") do |proc_io|
            proc_io << stream
            proc_io.close_write
            proc_io.read
          end
        end
      end

      def decode(format, data)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        IO.popen(["magick", "#{format}:-", "pam:-"], "r+") do |proc_io|
          proc_io << data
          proc_io.close_write

          frames = []
          while (frame = read_pam_frame(proc_io))
            frames << frame
          end

          if frames.length == 1
            frames.first
          else
            first = frames.first
            img = Image.new(first.width, first.height, frames.length,
                            color_bits: first.color_bits, channels: first.channels)
            frames.each_with_index do |frame, idx|
              offset = img.buffer.offset_of(0, 0, idx)
              bytes = frame.width * frame.height * frame.pixel_bytes
              img.buffer.io_buffer.copy(frame.buffer.io_buffer, offset, bytes)
            end
            img
          end
        end
      end

      def read_pam_frame(io)
        header = {}
        line = io.gets
        return nil unless line && line.chomp == "P7"

        line = io.gets
        return nil unless line

        until line.chomp == "ENDHDR"
          key, val = line.chomp.split(" ", 2)
          header[key] = val
          line = io.gets
          return nil unless line
        end

        width = header["WIDTH"].to_i
        height = header["HEIGHT"].to_i
        depth = header["DEPTH"].to_i
        maxval = header["MAXVAL"].to_i
        bits = Math.log2(maxval + 1).to_i
        bytes = width * height * depth * (bits / 8)
        raw = io.read(bytes)
        return nil unless raw && raw.bytesize == bytes

        buf = Image::Buffer.new([width, height], bits, depth, IO::Buffer.for(raw))
        Image.from_buffer(buf)
      end
    end
  end
end

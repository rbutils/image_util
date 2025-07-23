# frozen_string_literal: true

module ImageUtil
  module Codec
    module ChunkyPng
      SUPPORTED_FORMATS = [:png].freeze

      extend Guard

      begin
        require "chunky_png"
        AVAILABLE = true
      rescue LoadError
        AVAILABLE = false
      end

      module_function

      def supported?(format = nil)
        return false unless AVAILABLE

        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        raise UnsupportedFormatError, "chunky_png not available" unless AVAILABLE

        guard_2d_image!(image)
        guard_8bit_colors!(image)

        raw = if image.channels == 4
                image.buffer.get_string
              else
                data = String.new(capacity: image.width * image.height * 4)
                buf = image.buffer
                idx = 0
                step = buf.pixel_bytes
                image.height.times do
                  image.width.times do
                    color = buf.get_index(idx)
                    data << color[0].chr << color[1].chr << color[2].chr << 255.chr
                    idx += step
                  end
                end
                data
              end

        png = ::ChunkyPNG::Image.from_rgba_stream(image.width, image.height, raw)
        png.to_blob
      end

      def decode(format, data)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        raise UnsupportedFormatError, "chunky_png not available" unless AVAILABLE

        png = ::ChunkyPNG::Image.from_blob(data)
        raw = png.to_rgba_stream
        io_buf = IO::Buffer.for(raw)
        buf = Image::Buffer.new([png.width, png.height], 8, 4, io_buf)
        Image.from_buffer(buf)
      end
    end
  end
end

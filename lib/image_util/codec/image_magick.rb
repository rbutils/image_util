# frozen_string_literal: true

module ImageUtil
  module Codec
    module ImageMagick
      SUPPORTED_FORMATS = %i[sixel jpeg png].freeze

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
        pam = Codec::Pam.encode(:pam, image, fill_to: fmt == "sixel" ? 6 : nil)

        IO.popen(["magick", "pam:-", "#{fmt}:-"], "r+") do |proc_io|
          proc_io << pam
          proc_io.close_write
          proc_io.read
        end
      end

      def encode_io(format, image, io)
        io << encode(format, image)
      end

      def decode(format, data)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        IO.popen(["magick", "#{format}:-", "pam:-"], "r+") do |proc_io|
          proc_io << data
          proc_io.close_write
          Pam.decode(:pam, proc_io.read)
        end
      end

      def decode_io(format, io)
        decode(format, io.read)
      end
    end
  end
end

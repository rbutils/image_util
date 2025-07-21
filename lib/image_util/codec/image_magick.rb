# frozen_string_literal: true

module ImageUtil
  module Codec
    module ImageMagick
      SUPPORTED_FORMATS = [:sixel].freeze

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

        IO.popen("magick pam:- sixel:-", "r+") do |io|
          io << Codec::Pam.encode(:pam, image, fill_to: 6)
          io.close_write
          io.read
        end
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

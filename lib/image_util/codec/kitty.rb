# frozen_string_literal: true

require "base64"

module ImageUtil
  module Codec
    module Kitty
      SUPPORTED_FORMATS = [:kitty].freeze

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

        bits = image.pixel_bytes * 8
        width = image.width
        height = image.height

        rest = Base64.strict_encode64(image.buffer.get_string)

        first = true

        out = +""

        loop do
          payload, rest = rest[...4096], rest[4096..] # rubocop:disable Style/ParallelAssignment

          opts = {}

          if first
            opts[:f] = bits
            opts[:s] = width
            opts[:v] = height
            opts[:a] = "T" # immediately display
            opts[:q] = 2   # don't report anything
            opts[:m] = 1 if rest
          elsif rest
            opts[:m] = 1
          else
            opts[:m] = 0
          end

          opts = opts.map { |k,v| "#{k}=#{v}" }.join(",")
            
          out << "\e_G#{opts};#{payload}\e\\".b

          first = false
          break unless rest
        end

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

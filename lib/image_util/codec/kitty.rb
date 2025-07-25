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

      # Kitty format supports more options:
      # https://sw.kovidgoyal.net/kitty/graphics-protocol/#control-data-reference
      def encode(format, image, options: nil)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        guard_image_class!(image)
        guard_8bit_colors!(image)
        raise ArgumentError, "only 1d or 2d images supported" if image.dimensions.length > 2

        img = image
        img = img.redimension(img.width, 1) if img.dimensions.length == 1

        bits = img.pixel_bytes * 8
        width = img.width
        height = img.height

        rest = Base64.strict_encode64(img.buffer.get_string)

        first = true

        out = +""

        options ||= begin
          opts = {}
          opts[:a] = "T" # immediately display
          opts[:q] = 2   # don't report anything
          opts
        end

        loop do
          payload, rest = rest[...4096], rest[4096..] # rubocop:disable Style/ParallelAssignment

          opts = {}

          if first
            opts = opts.merge(options)
            opts[:f] = bits
            opts[:s] = width
            opts[:v] = height
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

      def decode(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end
    end
  end
end

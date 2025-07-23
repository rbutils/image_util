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
        guard_2d_image!(image)
        guard_8bit_colors!(image)

        bits = image.pixel_bytes * 8
        width = image.width
        height = image.height

        rest = Base64.strict_encode64(image.buffer.get_string)

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

      def encode_animation(format, image, gap: 50)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        guard_image_class!(image)
        raise ArgumentError, "only 3D images supported" unless image.dimensions.length == 3
        guard_8bit_colors!(image)

        id = rand(1 << 30)
        buffers = image.buffer.last_dimension_split
        first, *rest = buffers

        out = encode(format, Image.from_buffer(first), options: { a: "T", i: id, q: 2 })

        rest.each do |buffer|
          out << encode(format, Image.from_buffer(buffer), options: { a: "f", i: id, q: 2 })
        end

        out << "\e_Ga=a,i=#{id},s=3,v=1,z=#{gap}\e\\".b
      end

      def decode(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end
    end
  end
end

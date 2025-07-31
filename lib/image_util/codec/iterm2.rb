# frozen_string_literal: true

require "base64"

module ImageUtil
  module Codec
    module ITerm2
      SUPPORTED_FORMATS = [:iterm2].freeze

      extend Guard

      module_function

      def supported?(format = nil)
        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image, options: nil)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        guard_image_class!(image)
        guard_8bit_colors!(image)
        raise ArgumentError, "only 1d or 2d images supported" if image.dimensions.length > 2

        img = image
        img = img.redimension(img.width, 1) if img.dimensions.length == 1

        data = Codec.encode(:png, img)
        encoded = Base64.strict_encode64(data)

        opts = options&.map { |k, v| "#{k}=#{v}" }&.join(";")
        opts = opts ? "#{opts};inline=1" : "inline=1"

        "\e]1337;File=#{opts}:#{encoded}\a".b
      end

      def decode(*)
        raise UnsupportedFormatError, "decode not supported for iterm2"
      end
    end
  end
end

# frozen_string_literal: true

module ImageUtil
  module Codec
    module Guard
      def guard_supported_format!(format, supported)
        return if supported.map { |f| f.to_s.downcase.to_sym }.include?(format.to_s.downcase.to_sym)

        raise UnsupportedFormatError, "unsupported format #{format}"
      end

      def guard_image_class!(image)
        return if image.is_a?(Image)

        raise ArgumentError, "image must be an ImageUtil::Image"
      end

      def guard_2d_image!(image)
        guard_image_class!(image)
        return if image.dimensions.length == 2

        raise ArgumentError, "only 2D images supported"
      end

      def guard_8bit_colors!(image)
        guard_image_class!(image)
        return if image.color_bits == 8

        raise ArgumentError, "only 8-bit colors supported"
      end

      module_function :guard_supported_format!, :guard_image_class!, :guard_2d_image!, :guard_8bit_colors!
    end
  end
end

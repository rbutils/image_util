# frozen_string_literal: true

module ImageUtil
  module Filter
    module Paste
      extend ImageUtil::Filter::Mixin

      def paste!(image, *location, respect_alpha: false)
        raise TypeError, "image must be an Image" unless image.is_a?(Image)

        image.each_pixel_location do |loc|
          dest = location.zip(loc).map { |a, b| a + b }
          begin
            if respect_alpha
              self[*dest] += image[*loc]
            else
              self[*dest] = image[*loc]
            end
          rescue IndexError
            # ignore pixels outside bounds
          end
        end

        self
      end

      define_immutable_version :paste
    end
  end
end

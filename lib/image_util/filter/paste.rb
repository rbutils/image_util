# frozen_string_literal: true

module ImageUtil
  module Filter
    module Paste
      extend ImageUtil::Filter::Mixin

      def paste!(image, *location, respect_alpha: false)
        raise TypeError, "image must be an Image" unless image.is_a?(Image)

        last_dim = image.dimensions.length - 1

        image.each_with_index do |val, idx|
          new_loc = location.dup
          new_loc[last_dim] += idx

          begin
            if val.is_a?(Image)
              paste!(val, *new_loc, respect_alpha: respect_alpha)
            elsif respect_alpha
              self[*new_loc] += val
            else
              self[*new_loc] = val
            end
          rescue IndexError
            # do nothing, image overlaps
          end
        end

        self
      end

      define_immutable_version :paste
    end
  end
end

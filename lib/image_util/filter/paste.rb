# frozen_string_literal: true

module ImageUtil
  module Filter
    module Paste
      extend ImageUtil::Filter::Mixin

      def paste!(image, *location, respect_alpha: false)
        raise TypeError, "image must be an Image" unless image.is_a?(Image)

        if !respect_alpha &&
           image.dimensions.length == 1 &&
           image.color_bits == color_bits &&
           image.channels == channels &&
           buffer.respond_to?(:copy_1d)
          loc = location.map(&:to_i)
          begin
            check_bounds!(loc)
          rescue IndexError
            return self
          end

          if loc.first + image.length <= width
            buffer.copy_1d(image.buffer, *loc)
            return self
          end
        end

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

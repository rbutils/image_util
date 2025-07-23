# frozen_string_literal: true

module ImageUtil
  module Filter
    module Transform
      extend ImageUtil::Filter::Mixin

      def flip!(axis = :x)
        axis = Filter::Mixin.axis_to_number(axis)
        dims = dimensions
        out = Image.new(*dims, color_bits: color_bits, channels: channels)
        each_pixel_location do |loc|
          new_loc = loc.dup
          new_loc[axis] = dims[axis] - 1 - loc[axis]
          out[*new_loc] = self[*loc]
        end
        initialize_from_buffer(out.buffer)
        self
      end

      def rotate!(angle, axes: %i[x y])
        axes = axes.map { |a| Filter::Mixin.axis_to_number(a) }
        turns = (angle.to_f / 90).round % 4
        turns += 4 if turns.negative?
        turns.times { rotate90_once!(*axes) }
        self
      end

      define_immutable_version :flip, :rotate

      private

      def rotate90_once!(axis1 = 0, axis2 = 1)
        dims = dimensions
        new_dims = dims.dup
        new_dims[axis1], new_dims[axis2] = dims[axis2], dims[axis1] # rubocop:disable Style/ParallelAssignment
        out = Image.new(*new_dims, color_bits: color_bits, channels: channels)
        each_pixel_location do |loc|
          new_loc = loc.dup
          new_loc[axis1] = dims[axis2] - 1 - loc[axis2]
          new_loc[axis2] = loc[axis1]
          out[*new_loc] = self[*loc]
        end
        initialize_from_buffer(out.buffer)
      end
    end
  end
end

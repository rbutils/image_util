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

      def rotate!(angle)
        turns = (angle.to_f / 90).round % 4
        turns += 4 if turns.negative?
        turns.times { rotate90_once! }
        self
      end

      define_immutable_version :flip, :rotate

      private

      def rotate90_once!
        w = width
        h = height
        rest = dimensions[2..]
        out = Image.new(h, w, *rest, color_bits: color_bits, channels: channels)
        each_pixel_location do |loc|
          x = loc[0]
          y = loc[1]
          new_loc = [h - 1 - y, x, *loc[2..]]
          out[*new_loc] = self[*loc]
        end
        initialize_from_buffer(out.buffer)
      end
    end
  end
end

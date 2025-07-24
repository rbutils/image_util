# frozen_string_literal: true

module ImageUtil
  module Filter
    module Redimension
      extend ImageUtil::Filter::Mixin

      def redimension!(*new_dimensions)
        out = Image.new(*new_dimensions, color_bits: color_bits, channels: channels)

        copy_counts = new_dimensions.map.with_index do |dim, idx|
          [dim, dimensions[idx] || 1].min
        end

        ranges = copy_counts[1..] || []
        each_coordinates(ranges) do |coords|
          src_buf = row_buffer(coords)
          out.buffer.copy_1d(src_buf, 0, *coords)
        end

        initialize_from_buffer(out.buffer)
        self
      end

      define_immutable_version :redimension

      private

      def each_coordinates(ranges, prefix = [], &block)
        if ranges.empty?
          yield prefix
        else
          ranges.first.times do |i|
            each_coordinates(ranges[1..], prefix + [i], &block)
          end
        end
      end

      def row_buffer(coords)
        buf = buffer
        coords_src = coords[0, dimensions.length - 1]
        coords_src += [0] * (dimensions.length - 1 - coords_src.length)
        coords_src.reverse_each { |c| buf = buf.last_dimension(c) }
        buf
      end
    end
  end
end

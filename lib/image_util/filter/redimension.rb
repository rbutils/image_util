# frozen_string_literal: true

module ImageUtil
  module Filter
    module Redimension
      extend ImageUtil::Filter::Mixin

      def redimension!(*new_dimensions)
        if fast_redimension?(new_dimensions)
          begin
            resize_buffer!(new_dimensions)
            return self
          rescue StandardError
            # fall back to generic implementation
          end
        end

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

      def fast_redimension?(new_dimensions)
        io = buffer.io_buffer
        return false unless io.respond_to?(:resize)
        return false if io.external? || io.locked?

        dims = dimensions

        min_len = [dims.length, new_dimensions.length].min
        idx = 0
        idx += 1 while idx < min_len && dims[idx] == new_dimensions[idx]

        return false if idx == dims.length && idx == new_dimensions.length
        return false unless (dims[(idx + 1)..] || []).all? { |d| d == 1 }
        return false unless (dims[new_dimensions.length..] || []).all? { |d| d == 1 }

        true
      end

      def resize_buffer!(new_dimensions)
        new_size = new_dimensions.reduce(1, :*)
        new_size *= channels
        new_size *= color_bits / 8
        buffer.io_buffer.resize(new_size)
        initialize_from_buffer(Image::Buffer.new(new_dimensions, color_bits, channels, buffer.io_buffer))
      end

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

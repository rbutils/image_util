# frozen_string_literal: true

module ImageUtil
  module Filter
    module Dither
      private

      def dither_distance_sq(c1, c2)
        max_len = [c1.length, c2.length].max
        sum = 0
        max_len.times do |i|
          v1 = c1[i] || 255
          v2 = c2[i] || 255
          d = v1 - v2
          sum += d * d
        end
        sum
      end

      public

      def dither!(count)
        palette = histogram.sort_by { |_, v| -v }.first(count).map(&:first)

        set_each_pixel_by_location do |loc|
          color = self[*loc]
          palette.min_by { |p| dither_distance_sq(color, p) }
        end
        self
      end

      def dither(count) = dup.tap { |i| i.dither!(count) }
    end
  end
end

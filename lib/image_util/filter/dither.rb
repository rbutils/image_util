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
        histogram = Hash.new(0)
        each_pixel_location do |loc|
          histogram[self[*loc].to_a] += 1
        end
        palette = histogram.sort_by { |_, v| -v }.first(count).map { |c, _| Color[*c] }

        each_pixel_location do |loc|
          color = self[*loc]
          best = palette.min_by { |p| dither_distance_sq(color, p) }
          self[*loc] = best
        end
        self
      end

      def dither(count) = dup.tap { |i| i.dither!(count) }
    end
  end
end

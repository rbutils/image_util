# frozen_string_literal: true

module ImageUtil
  module Filter
    module Dither
      extend ImageUtil::Filter::Mixin

      private

      def dither_distance_sq(c1, c2)
        len = [c1.length, c2.length].max

        case len
        when 1
          d = (c1[0] || 255) - (c2[0] || 255)
          d * d
        when 2
          d0 = (c1[0] || 255) - (c2[0] || 255)
          d1 = (c1[1] || 255) - (c2[1] || 255)
          d0 * d0 + d1 * d1
        when 3
          d0 = (c1[0] || 255) - (c2[0] || 255)
          d1 = (c1[1] || 255) - (c2[1] || 255)
          d2 = (c1[2] || 255) - (c2[2] || 255)
          d0 * d0 + d1 * d1 + d2 * d2
        when 4
          d0 = (c1[0] || 255) - (c2[0] || 255)
          d1 = (c1[1] || 255) - (c2[1] || 255)
          d2 = (c1[2] || 255) - (c2[2] || 255)
          d3 = (c1[3] || 255) - (c2[3] || 255)
          d0 * d0 + d1 * d1 + d2 * d2 + d3 * d3
        else
          sum = 0
          len.times do |i|
            d = (c1[i] || 255) - (c2[i] || 255)
            sum += d * d
          end
          sum
        end
      end

      public

      def dither!(count)
        palette = histogram.sort_by { |_, v| -v - rand }.first(count).map(&:first)

        cache = {}

        nearest = lambda do |color|
          key = (color[0] || 255) |
                ((color[1] || 255) << 8) |
                ((color[2] || 255) << 16) |
                ((color[3] || 255) << 24)
          cache[key] ||= begin
            best = palette.first
            best_dist = dither_distance_sq(color, best)
            idx = 1
            while idx < palette.length
              c = palette[idx]
              dist = dither_distance_sq(color, c)
              if dist < best_dist
                best = c
                best_dist = dist
              end
              idx += 1
            end
            best
          end
        end

        if dimensions.length == 2
          w = width
          h = height
          buf = buffer
          idx = 0
          step = buf.pixel_bytes
          h.times do
            w.times do
              color = buf.get_index(idx)
              buf.set_index(idx, nearest.call(color))
              idx += step
            end
          end
        else
          set_each_pixel_by_location do |loc|
            color = self[*loc]
            nearest.call(color)
          end
        end
        self
      end

      define_immutable_version :dither
    end
  end
end

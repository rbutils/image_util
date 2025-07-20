# frozen_string_literal: true

module ImageUtil
  module Filter
    module Background
      def background!(color = Color[:black])
        each_pixel_location do |loc|
          self[*loc] = Color[color] + self[*loc]
        end
        self
      end

      def background(color = Color[:black]) = dup.tap { |i| i.background!(color) }
    end
  end
end

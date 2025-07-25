# frozen_string_literal: true

module ImageUtil
  module Filter
    module Colors
      extend ImageUtil::Filter::Mixin

      def color_multiply!(color)
        col = Color.from(color)
        set_each_pixel_by_location! do |loc|
          self[*loc] * col
        end
        self
      end

      define_immutable_version :color_multiply

      alias * color_multiply
    end
  end
end

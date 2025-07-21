# frozen_string_literal: true

module ImageUtil
  module Filter
    module Resize
      def resize(new_width, new_height, view: View::Interpolated)
        src = self.view(view)

        factor_x = new_width == 1 ? 0.0 : (width - 1).to_f / (new_width - 1)
        factor_y = new_height == 1 ? 0.0 : (height - 1).to_f / (new_height - 1)

        Image.new(new_width, new_height, color_bits: color_bits, color_length: color_length).tap do |out|
          out.set_each_pixel_by_location do |x, y|
            out[x, y] = src[x * factor_x, y * factor_y]
          end
        end
      end
    end
  end
end

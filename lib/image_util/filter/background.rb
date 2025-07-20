# frozen_string_literal: true

module ImageUtil
  module Filter
    module Background
      def background!(bgcolor)
        return self if color_length == 3

        unless color_length == 4
          raise ArgumentError, "background only supported on RGB or RGBA images"
        end

        bg = Color.from(bgcolor)
        img = Image.new(*dimensions, color_bits: color_bits, color_length: 3)
        img.set_each_pixel_by_location do |loc|
          over = bg + self[*loc]
          Color.new(over.r, over.g, over.b)
        end
        initialize_from_buffer(img.buffer)
        self
      end

      def background(bgcolor)
        return self if color_length == 3

        dup.tap { |i| i.background!(bgcolor) }
      end
    end
  end
end

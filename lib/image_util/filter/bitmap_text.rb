# frozen_string_literal: true

module ImageUtil
  module Filter
    module BitmapText
      extend ImageUtil::Filter::Mixin

      def bitmap_text!(text, x = 0, y = 0, **kwargs)
        paste!(Image.bitmap_text(text, **kwargs), x, y)
      end

      define_immutable_version :bitmap_text
    end
  end
end

# frozen_string_literal: true

module ImageUtil
  module Filter
    module BitmapText
      extend ImageUtil::Filter::Mixin

      def bitmap_text!(text, *location, **kwargs)
        loc = location.dup
        loc += [0] * (dimensions.length - loc.length)
        paste!(Image.bitmap_text(text, **kwargs), *loc)
      end

      define_immutable_version :bitmap_text
    end
  end
end

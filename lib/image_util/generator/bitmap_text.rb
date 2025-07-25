# frozen_string_literal: true

module ImageUtil
  module Generator
    module BitmapText
      def bitmap_text(text, font: BitmapFont.default_font)
        fnt = BitmapFont.cached_load(font)
        fnt.render_line_of_text(text)
      end
    end
  end
end 

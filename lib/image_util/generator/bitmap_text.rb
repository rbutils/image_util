# frozen_string_literal: true

module ImageUtil
  module Generator
    module BitmapText
      def bitmap_text(text, font: BitmapFont.default_font, color: nil)
        fnt = BitmapFont.cached_load(font)
        lines = text.split("\n")

        rendered = lines.map { |line| fnt.render_line_of_text(line) }

        width  = rendered.map(&:width).max || 0
        height = rendered.map(&:height).first.to_i * rendered.length
        height += rendered.length - 1 if rendered.length > 1

        out = Image.new(width, height)
        y = 0
        rendered.each do |img|
          out.paste!(img, 0, y)
          y += img.height + 1
        end

        out *= color if color
        out
      end
    end
  end
end 

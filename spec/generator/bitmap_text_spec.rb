require 'spec_helper'

RSpec.describe ImageUtil::Generator::BitmapText do
  describe '#bitmap_text' do
    it 'renders multiline colored text' do
      font = ImageUtil::BitmapFont.default_font
      img = ImageUtil::Image.bitmap_text("A\nB", font: font, color: :red)
      line_height = ImageUtil::BitmapFont.cached_load(font).render_line_of_text("A").height
      img.height.should == line_height * 2 + 1
      red = ImageUtil::Color[:red]
      img.each_pixel.any? { |c| c.r == red.r && c.g == red.g && c.b == red.b && c.a > 0 }.should be true
    end

    it 'aligns text according to option' do
      font = ImageUtil::BitmapFont.default_font
      img = ImageUtil::Image.bitmap_text("AB\nA", font: font, align: :right)
      loader = ImageUtil::BitmapFont.cached_load(font)
      width  = loader.render_line_of_text("AB").width
      line_height = loader.render_line_of_text("A").height
      img.width.should == width
      y = line_height + 1
      (0...(width - loader.render_line_of_text("A").width)).all? { |x| img[x, y].a.zero? }.should be true
    end
  end
end

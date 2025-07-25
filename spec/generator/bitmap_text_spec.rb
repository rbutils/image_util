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
  end
end

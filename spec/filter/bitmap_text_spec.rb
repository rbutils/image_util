require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#bitmap_text!' do
    it 'pastes rendered text at location' do
      base = described_class.new(16, 16) { ImageUtil::Color[0] }
      font = ImageUtil::BitmapFont.default_font
      text = described_class.bitmap_text('A', font: font)
      base.bitmap_text!('A', 2, 3, font: font)
      text.each_pixel_location do |(x, y)|
        base[x + 2, y + 3].should == text[x, y]
      end
    end

    it 'accepts coordinates for extra dimensions' do
      base = described_class.new(16, 16, 2) { ImageUtil::Color[0] }
      font = ImageUtil::BitmapFont.default_font
      text = described_class.bitmap_text('A', font: font)
      base.bitmap_text!('A', 1, 1, 1, font: font)
      text.each_pixel_location do |(x, y)|
        base[x + 1, y + 1, 1].should == text[x, y]
      end
      base[1, 1, 0].should == ImageUtil::Color[0]
    end
  end

  describe '#bitmap_text' do
    it 'returns new image without modifying original' do
      img = described_class.new(4, 4)
      dup = img.bitmap_text('A')
      dup.should_not equal(img)
    end
  end
end

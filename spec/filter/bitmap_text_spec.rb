require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#bitmap_text!' do
    it 'pastes rendered text at location' do
      base_color = ImageUtil::Color[0]
      base = described_class.new(16, 16) { base_color }
      font = ImageUtil::BitmapFont.default_font
      text = described_class.bitmap_text('A', font: font)
      base.bitmap_text!('A', 2, 3, font: font)
      text.each_pixel_location do |(x, y)|
        expected = if text[x, y].a.zero?
                     base_color
                   else
                     base_color + text[x, y]
                   end
        expected = ImageUtil::Color.new(*expected.map(&:to_i))
        base[x + 2, y + 3].should == expected
      end
    end

    it 'accepts coordinates for extra dimensions' do
      base_color = ImageUtil::Color[0]
      base = described_class.new(16, 16, 2) { base_color }
      font = ImageUtil::BitmapFont.default_font
      text = described_class.bitmap_text('A', font: font)
      base.bitmap_text!('A', 1, 1, 1, font: font)
      text.each_pixel_location do |(x, y)|
        expected = if text[x, y].a.zero?
                     base_color
                   else
                     base_color + text[x, y]
                   end
        expected = ImageUtil::Color.new(*expected.map(&:to_i))
        base[x + 1, y + 1, 1].should == expected
      end
      base[1, 1, 0].should == base_color
    end

    it 'respects alpha channel of rendered text' do
      font = ImageUtil::BitmapFont.default_font
      color = ImageUtil::Color[20, 0, 0, 128]
      text  = described_class.bitmap_text('A', font: font, color: color)
      base_color = ImageUtil::Color[10, 20, 30]
      base = described_class.new(text.width, text.height) { base_color }
      base.bitmap_text!('A', 0, 0, font: font, color: color)
      text.each_pixel_location do |(x, y)|
        expected = if text[x, y].a.zero?
                     base_color
                   else
                     base_color + text[x, y]
                   end
        expected = ImageUtil::Color.new(*expected.map(&:to_i))
        base[x, y].should == expected
      end
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

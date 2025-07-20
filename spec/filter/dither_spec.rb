require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#dither!' do
    it 'reduces colors in place' do
      img = described_class.new(4,1) { |x,_| ImageUtil::Color[x*50,0,0] }
      img.dither!(2)
      colors = []
      img.each_pixel { |c| colors << c.to_a }
      colors.uniq.length.should <= 2
    end
  end

  describe '#dither' do
    it 'returns new image without modifying original' do
      img = described_class.new(2,1) { |x,_| ImageUtil::Color[x*100,0,0] }
      dup = img.dither(1)
      dup.should_not equal(img)
      orig_colors = []
      img.each_pixel { |c| orig_colors << c.to_a }
      new_colors = []
      dup.each_pixel { |c| new_colors << c.to_a }
      orig_colors.uniq.length.should == 2
      new_colors.uniq.length.should == 1
    end
  end
end

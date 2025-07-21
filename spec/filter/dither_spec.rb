require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#dither!' do
    it 'reduces colors in place' do
      img = described_class.new(4,1) { |x,_| ImageUtil::Color[x*50,0,0] }
      img.dither!(2)
      img.unique_color_count.should <= 2
    end
  end

  describe '#dither' do
    it 'returns new image without modifying original' do
      img = described_class.new(2,1) { |x,_| ImageUtil::Color[x*100,0,0] }
      dup = img.dither(1)
      dup.should_not equal(img)
      img.unique_color_count.should == 2
      dup.unique_color_count.should == 1
    end
  end
end

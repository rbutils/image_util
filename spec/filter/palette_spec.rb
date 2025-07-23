require 'spec_helper'

RSpec.describe ImageUtil::Filter::Palette do
  describe '#palette_reduce!' do
    it 'reduces colors in place' do
      img = ImageUtil::Image.new(4,1) { |x,_| ImageUtil::Color[x*50,0,0] }
      img.palette_reduce!(2)
      img.unique_color_count.should <= 2
    end
  end

  describe '#palette_reduce' do
    it 'returns new image without modifying original' do
      img = ImageUtil::Image.new(2,1) { |x,_| ImageUtil::Color[x*100,0,0] }
      dup = img.palette_reduce(1)
      dup.should_not equal(img)
      img.unique_color_count.should == 2
      dup.unique_color_count.should == 1
    end
  end
end

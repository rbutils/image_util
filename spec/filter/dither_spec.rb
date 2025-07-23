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

  describe '#dither!' do
    it 'handles images with more than two dimensions' do
      img = described_class.new(2, 1, 2) { |x, _, z| ImageUtil::Color[x * 50, 0, z * 50] }
      img.dither!(2)
      img.unique_color_count.should <= 2
    end
  end

  describe '#dither_distance_sq' do
    it 'computes squared distance for varying color lengths' do
      img = described_class.new(1,1)
      img.send(:dither_distance_sq, [1], [0]).should == 1
      img.send(:dither_distance_sq, [1,2], [0,0]).should == 5
      img.send(:dither_distance_sq, [1,2,3], [0,0,0]).should == 14
      img.send(:dither_distance_sq, [1,2,3,4], [0,0,0,0]).should == 30
      img.send(:dither_distance_sq, [1,2,3,4,5], [0,0,0,0,0]).should == 55
    end
  end
end

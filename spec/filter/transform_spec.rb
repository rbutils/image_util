require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#flip!' do
    it 'flips pixels along the given axis' do
      img = described_class.new(2, 1) { |x, _| ImageUtil::Color[x] }
      img.flip!(:x)
      img[0,0].should == ImageUtil::Color[1]
      img[1,0].should == ImageUtil::Color[0]
    end
  end

  describe '#flip' do
    it 'returns new image without modifying original' do
      img = described_class.new(2, 1) { |x, _| ImageUtil::Color[x] }
      dup = img.flip(:x)
      dup.should_not equal(img)
      dup[0,0].should == ImageUtil::Color[1]
      img[0,0].should == ImageUtil::Color[0]
    end
  end

  describe '#rotate!' do
    it 'rotates image by 90 degrees' do
      img = described_class.new(2, 3, channels: 1) { |x, y| ImageUtil::Color.new(x + y*10) }
      img.rotate!(90)
      img.dimensions.should == [3, 2]
      img[0,0].should == ImageUtil::Color.new(20)
      img[2,1].should == ImageUtil::Color.new(1)
    end

    it 'handles negative rotations' do
      img = described_class.new(2, 1) { |x, _| ImageUtil::Color[x] }
      img.rotate!(-180)
      img[0,0].should == ImageUtil::Color[1]
    end

    it 'works with more than two dimensions' do
      img = described_class.new(2, 2, 1, 1, 1, 1, 1, 1) { |x, y, *_| ImageUtil::Color[x + y] }
      img.rotate!(90)
      img.dimensions[0,2].should == [2,2]
      img[0,0,0,0,0,0,0,0].should == ImageUtil::Color[1]
    end
  end

  describe '#rotate' do
    it 'returns new image without modifying original' do
      img = described_class.new(1, 2) { |_, y| ImageUtil::Color[y] }
      dup = img.rotate(180)
      dup.should_not equal(img)
      dup[0,0].should == ImageUtil::Color[1]
      img[0,0].should == ImageUtil::Color[0]
    end
  end
end

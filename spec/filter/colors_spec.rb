require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#color_multiply!' do
    it 'multiplies image colors in place' do
      img = described_class.new(1,1) { ImageUtil::Color[100, 200, 50] }
      img.color_multiply!(ImageUtil::Color[128, 64, 255])
      expected = ImageUtil::Color[100, 200, 50] * ImageUtil::Color[128, 64, 255]
      img[0,0].r.should be_within(0.01).of(expected.r)
      img[0,0].g.should be_within(0.01).of(expected.g)
      img[0,0].b.should be_within(0.01).of(expected.b)
    end
  end

  describe '#color_multiply' do
    it 'returns new image without modifying original' do
      img = described_class.new(1,1) { ImageUtil::Color[10,20,30] }
      dup = img.color_multiply(ImageUtil::Color[255,0,0])
      dup.should_not equal(img)
      dup[0,0].should == img[0,0] * ImageUtil::Color[255,0,0]
      img[0,0].should == ImageUtil::Color[10,20,30]
    end
  end

  describe '#*' do
    it 'aliases color_multiply' do
      img = described_class.new(1,1) { ImageUtil::Color[20,40,60] }
      dup = img * ImageUtil::Color[0,255,0]
      dup[0,0].should == img.color_multiply(ImageUtil::Color[0,255,0])[0,0]
    end
  end
end

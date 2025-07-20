require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#background!' do
    it 'applies background color in place' do
      img = described_class.new(1, 1) { ImageUtil::Color[0, 0, 0, 0] }
      img.background!(ImageUtil::Color[10, 10, 10])
      img[0,0].should == ImageUtil::Color[10,10,10]
    end
  end

  describe '#background' do
    it 'returns new image with background applied' do
      img = described_class.new(1, 1) { ImageUtil::Color[0, 0, 0, 0] }
      dup = img.background(ImageUtil::Color[20, 0, 0])
      dup.should_not equal(img)
      dup[0,0].should == ImageUtil::Color[20,0,0]
      img[0,0].should == ImageUtil::Color[0,0,0,0]
    end
  end
end

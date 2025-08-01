require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#background' do
    it 'returns self for images without alpha' do
      img = described_class.new(1, 1, channels: 3) { ImageUtil::Color[1, 2, 3] }
      img.background(ImageUtil::Color[0]).should equal(img)
    end

    it 'applies background color for images with alpha' do
      img = described_class.new(1, 1) { ImageUtil::Color[255, 0, 0, 128] }
      out = img.background(ImageUtil::Color[0, 0, 255])
      out.should_not equal(img)
      out.channels.should == 3
      out[0, 0].should == ImageUtil::Color.new(128.0, 0.0, 127.0)
    end

    it 'raises on unsupported color length' do
      img = described_class.new(1, 1, channels: 2)
      -> { img.background(ImageUtil::Color[0]) }.should raise_error(ArgumentError)
    end
  end

  describe '#background!' do
    it 'flattens the image in place' do
      img = described_class.new(1, 1) { ImageUtil::Color[255, 0, 0, 128] }
      img.background!(ImageUtil::Color[0, 0, 255])
      img.channels.should == 3
      img[0, 0].should == ImageUtil::Color.new(128.0, 0.0, 127.0)
    end
  end
end

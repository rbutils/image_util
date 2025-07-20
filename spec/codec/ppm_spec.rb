require 'spec_helper'

RSpec.describe ImageUtil::Codec::Ppm do
  it 'encodes and decodes a PPM image' do
    img = ImageUtil::Image.new(2, 1) { |x, _| ImageUtil::Color[x*100, 0, 0] }
    data = described_class.encode(:ppm, img)
    data.start_with?("P6\n2 1\n255\n").should be true

    decoded = described_class.decode(:ppm, data)
    decoded.dimensions.should == [2, 1]
    decoded[1, 0].should == ImageUtil::Color[100, 0, 0]
  end

  it 'applies background color' do
    img = ImageUtil::Image.new(1,1) { ImageUtil::Color[0,0,255,128] }
    data = described_class.encode(:ppm, img, background: ImageUtil::Color[255,0,0])
    decoded = described_class.decode(:ppm, data)
    decoded[0,0].r.should be_between(127,128)
    decoded[0,0].b.should be_between(127,128)
  end
end

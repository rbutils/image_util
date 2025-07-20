require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libjpeg do
  before do
    skip 'libjpeg not available' unless described_class.supported?
  end

  it 'encodes and decodes a JPEG image' do
    img = ImageUtil::Image.new(2, 2) { ImageUtil::Color[255, 0, 0] }
    data = described_class.encode(:jpeg, img)
    data.start_with?("\xFF\xD8".b).should be true

    decoded = described_class.decode(:jpeg, data)
    decoded.dimensions.should == [2, 2]
    decoded[0, 0].r.should be > 200
    decoded[0, 0].g.should < 10
    decoded[0, 0].b.should < 10
  end

  it 'raises for unsupported color depth' do
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(:jpeg, img) }.should raise_error(ArgumentError)
  end
end

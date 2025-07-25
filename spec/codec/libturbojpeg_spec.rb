require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libturbojpeg do
  before do
    skip 'libturbojpeg not available' unless described_class.supported?
  end

  let(:img) { ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] } }

  it 'encodes and decodes a JPEG image' do
    data = described_class.encode(:jpeg, img)
    data.start_with?("\xFF\xD8".b).should be true

    decoded = described_class.decode(:jpeg, data)
    decoded.dimensions.should == [1, 1]
    c = decoded[0, 0]
    c.r.should be_between(250, 255)
    c.g.should == 0
    c.b.should == 0
  end

  it 'raises for unsupported color depth' do
    bad = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(:jpeg, bad) }.should raise_error(ArgumentError)
  end
end

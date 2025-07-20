require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libpng do
  it 'encodes and decodes a PNG image' do
    img = ImageUtil::Image.new(2, 1) { |x, _y| ImageUtil::Color[x, 0, 0] }
    data = described_class.encode(img)
    data.start_with?("\x89PNG\r\n\x1a\n".b).should be true

    decoded = described_class.decode(data)
    decoded.dimensions.should == [2, 1]
    decoded[1, 0].should == ImageUtil::Color[1, 0, 0]
  end

  it 'raises for unsupported color depth' do
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(img) }.should raise_error(ArgumentError)
  end
end

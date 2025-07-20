require 'spec_helper'

RSpec.describe 'PNG encoder/decoder' do
  it 'encodes and decodes a PNG image' do
    img = ImageUtil::Image.new(2, 1) { |x, _y| ImageUtil::Color[x, 0, 0] }
    data = ImageUtil::Encoder::PNG.encode(img)
    data.start_with?("\x89PNG\r\n\x1a\n".b).should be true

    decoded = ImageUtil::Decoder::PNG.decode(data)
    decoded.dimensions.should == [2, 1]
    decoded[1, 0].should == ImageUtil::Color[1, 0, 0]
  end

  it 'raises for unsupported color depth' do
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { ImageUtil::Encoder::PNG.encode(img) }.should raise_error(ArgumentError)
  end
end

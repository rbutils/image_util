require 'spec_helper'

RSpec.describe ImageUtil::Codec::ChunkyPng do
  before do
    skip 'chunky_png not available' unless described_class.supported?
  end

  it 'encodes and decodes a PNG image' do
    img = ImageUtil::Image.new(2, 1) { |x, _y| ImageUtil::Color[x, 0, 0] }
    data = described_class.encode(:png, img)
    data.start_with?("\x89PNG\r\n\x1a\n".b).should be true

    decoded = described_class.decode(:png, data)
    decoded.dimensions.should == [2, 1]
    decoded[1, 0].should == ImageUtil::Color[1, 0, 0]
  end

  it 'raises for unsupported color depth' do
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(:png, img) }.should raise_error(ArgumentError)
  end
end

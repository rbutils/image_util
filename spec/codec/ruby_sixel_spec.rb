require 'spec_helper'

RSpec.describe ImageUtil::Codec::RubySixel do
  it 'encodes an image to sixel' do
    img = ImageUtil::Image.new(2, 1) { |x, _| ImageUtil::Color[x * 255, 0, 0] }
    data = described_class.encode(:sixel, img)
    data.start_with?("\ePq\"1;1;2;1").should be true
    data.end_with?("\e\\").should be true
    data.match?(/#\d+;2;100;0;0/).should be true
  end

  it 'raises on bad input' do
    img = ImageUtil::Image.new(1,1,1)
    ->{ described_class.encode(:sixel, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1,1, color_bits: 16)
    ->{ described_class.encode(:sixel, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:foo, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'does not support decoding' do
    ->{ described_class.decode(:sixel, '') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    ->{ described_class.decode_io(:sixel, StringIO.new) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'dithers images with many colors' do
    img = ImageUtil::Image.new(300, 1) { |x, _| ImageUtil::Color[x % 256, x / 256, 0] }
    data = described_class.encode(:sixel, img)
    data.start_with?("\ePq").should be true
    data.end_with?("\e\\").should be true
  end
end

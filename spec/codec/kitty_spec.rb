require 'spec_helper'

RSpec.describe ImageUtil::Codec::Kitty do
  it 'encodes an image to the kitty protocol' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] }
    data = described_class.encode(:kitty, img)
    data.start_with?("\e_G").should be true
    data.end_with?("\e\\").should be true
  end

  it 'encodes 1d images' do
    img = ImageUtil::Image.new(3) { |loc| ImageUtil::Color[loc.first * 40, 0, 0] }
    data = described_class.encode(:kitty, img)
    data.start_with?("\e_G").should be true
  end

  it 'raises on bad input' do
    img = ImageUtil::Image.new(1, 1, 1)
    -> { described_class.encode(:kitty, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(:kitty, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1, 1)
    -> { described_class.encode(:foo, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'does not support decoding' do
    -> { described_class.decode(:kitty, '') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    -> { ImageUtil::Codec.decode_io(:kitty, StringIO.new, codec: described_class) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end
end

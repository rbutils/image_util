require 'spec_helper'

RSpec.describe ImageUtil::Codec::ITerm2 do
  it 'encodes an image to the iterm2 protocol' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] }
    data = described_class.encode(:iterm2, img)
    data.start_with?("\e]1337;File=").should be true
    data.end_with?("\a").should be true
  end

  it 'encodes 1d images' do
    img = ImageUtil::Image.new(2) { |loc| ImageUtil::Color[loc.first * 100, 0, 0] }
    data = described_class.encode(:iterm2, img)
    data.start_with?("\e]1337;File=").should be true
  end

  it 'raises on bad input' do
    img = ImageUtil::Image.new(1, 1, 1)
    -> { described_class.encode(:iterm2, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(:iterm2, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1, 1)
    -> { described_class.encode(:foo, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'does not support decoding' do
    -> { described_class.decode(:iterm2, '') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    -> { ImageUtil::Codec.decode_io(:iterm2, StringIO.new, codec: described_class) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end
end

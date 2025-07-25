require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libsixel do
  before do
    skip 'libsixel not available' unless described_class.supported?
  end

  it 'encodes an image to sixel' do
    img = ImageUtil::Image.new(2, 1) { |x,_| ImageUtil::Color[x * 255, 0, 0] }
    data = described_class.encode(:sixel, img)
    data.start_with?("\ePq").should be true
    data.end_with?("\e\\").should be true
  end

  it 'encodes 1d images' do
    img = ImageUtil::Image.new(3) { |loc| ImageUtil::Color[loc.first * 50, 0, 0] }
    data = described_class.encode(:sixel, img)
    data.start_with?("\ePq").should be true
  end

  it 'raises for unsupported format' do
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:foo, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end
end

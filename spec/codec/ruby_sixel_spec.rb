require 'spec_helper'

RSpec.describe ImageUtil::Codec::RubySixel do
  it 'encodes an image to sixel' do
    img = ImageUtil::Image.new(2, 1) { |x, _| ImageUtil::Color[x * 255, 0, 0] }
    data = described_class.encode(:sixel, img)
    data.start_with?("\ePq").should be true
    data.end_with?("\e\\").should be true
    data.include?('#0;2;100;0;0').should be true
  end
end

require 'spec_helper'

RSpec.describe ImageUtil::Converter::Sixel do
  it 'generates sixel for a single pixel' do
    img = ImageUtil::Image.new(1,1) { ImageUtil::Color[255,0,0] }
    sixel = described_class.convert(img)
    sixel.should == "\ePq#0;2;100;0;0#0@\e\\"
  end

  it 'works with 1D images' do
    img = ImageUtil::Image.new(2)
    img[0] = ImageUtil::Color[0]
    img[1] = ImageUtil::Color[128]
    sixel = described_class.convert(img)
    sixel.start_with?("\ePq").should be true
    sixel.end_with?("\e\\").should be true
  end
end

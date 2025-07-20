require 'spec_helper'

RSpec.describe ImageUtil::Converter::Sixel do
  it 'generates sixel for a single pixel' do
    img = ImageUtil::Image.new(1,1) { ImageUtil::Color[255,0,0] }
    sixel = described_class.convert(img)
    sixel.start_with?("\ePq\"1;1;1;1#0;2;0;0;0;4#1;2;100;0;0").should be true
    sixel.end_with?("\e\\").should be true
  end

  it 'works with 1D images' do
    img = ImageUtil::Image.new(2)
    img[0] = ImageUtil::Color[0]
    img[1] = ImageUtil::Color[128]
    sixel = described_class.convert(img)
    sixel.start_with?("\ePq\"1;1;1;1").should be true
    sixel.end_with?("\e\\").should be true
  end

  it 'defines transparent color for padding' do
    img = ImageUtil::Image.new(1,1) { ImageUtil::Color[0,0,255] }
    sixel = described_class.convert(img)
    sixel.include?('#0;2;0;0;0;4').should be true
  end

  it 'limits palette when too many colors are used' do
    img = ImageUtil::Image.new(256)
    256.times { |i| img[i] = ImageUtil::Color[i,0,0] }
    sixel = described_class.convert(img)
    sixel.scan(/#\d+;2/).length.should == 256
  end

  it 'encodes transparent pixels' do
    img = ImageUtil::Image.new(1,1) { ImageUtil::Color[255,0,0,0] }
    sixel = described_class.convert(img)
    sixel.include?(';4').should be true
  end
end

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

  it 'encodes transparency using palette index 0' do
    img = ImageUtil::Image.new(1,2)
    img[0,0] = ImageUtil::Color[255,0,0]
    img[0,1] = ImageUtil::Color[0,0,0,0]
    sixel = described_class.convert(img)
    sixel.include?('#0;2;0;0;0;4').should be true
    (sixel =~ /#0A/).nil?.should be false
  end

  it 'limits palette when too many colors are used' do
    img = ImageUtil::Image.new(300)
    300.times { |i| img[i] = ImageUtil::Color[i % 256, i % 256, i % 256] }
    sixel = described_class.convert(img)
    sixel.scan(/#\d+;2/).length.should <= 256
  end

  it 'encodes transparent pixels' do
    img = ImageUtil::Image.new(1,1) { ImageUtil::Color[255,0,0,0] }
    sixel = described_class.convert(img)
    sixel.include?(';4').should be true
  end

  it 'preserves colors when palette fits' do
    img = ImageUtil::Image.new(10,5) { |x,y| ImageUtil::Color[x,y] }
    sixel = described_class.convert(img)
    sixel.scan(/#\d+;2/).length.should == 51
  end

  it 'uses generated palette instead of defaults' do
    img = ImageUtil::Image.new(60,30) { |x,y| ImageUtil::Color[x/4, y/4] }
    sixel = described_class.convert(img)
    sixel.scan(/#\d+;2/).length.should == 121
  end
end

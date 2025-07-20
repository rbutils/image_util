require 'spec_helper'

RSpec.describe ImageUtil::Codec::Pam do
  it 'encodes and decodes a PAM image' do
    img = ImageUtil::Image.new(2, 1) { |x,_| ImageUtil::Color[x,0,0] }
    data = described_class.encode(:pam, img, fill_to: 2)
    data.lines.first.chomp.should == 'P7'
    data = data.sub('MAXVAL 63', 'MAXVAL 255')
    decoded = described_class.decode(:pam, data)
    decoded.dimensions.should == [2,2]
    decoded[1,0].should == ImageUtil::Color[1,0,0,255]
  end

  it 'raises for unsupported format' do
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:foo, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    ->{ described_class.decode(:foo, '') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'raises when converting invalid images' do
    img = ImageUtil::Image.new(1,1,1)
    ->{ described_class.encode(:pam, img) }.should raise_error(ArgumentError)
    img = ImageUtil::Image.new(1,1, color_length: 2)
    ->{ described_class.encode(:pam, img) }.should raise_error(ArgumentError)
  end
end

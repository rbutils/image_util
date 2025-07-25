require 'spec_helper'

RSpec.describe ImageUtil::Codec::Pam do
  it 'encodes and decodes a PAM image' do
    img = ImageUtil::Image.new(2, 1) { |x,_| ImageUtil::Color[x,0,0] }
    data = described_class.encode(:pam, img)
    data.lines.first.chomp.should == 'P7'
    decoded = described_class.decode(:pam, data)
    decoded.dimensions.should == [2,1]
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
    img = ImageUtil::Image.new(1,1, channels: 2)
    ->{ described_class.encode(:pam, img) }.should raise_error(ArgumentError)
  end

  it 'decodes multiple frames from an IO stream' do
    img1 = ImageUtil::Image.new(1, 1) { ImageUtil::Color[0, 0, 0] }
    img2 = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 255, 255] }
    data = described_class.encode(:pam, img1) + described_class.encode(:pam, img2)
    io = StringIO.new(data)
    f1 = described_class.decode_frame(io)
    f2 = described_class.decode_frame(io)
    f1[0, 0].should == ImageUtil::Color[0, 0, 0, 255]
    f2[0, 0].should == ImageUtil::Color[255, 255, 255, 255]
  end
end

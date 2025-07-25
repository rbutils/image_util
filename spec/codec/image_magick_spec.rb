require 'spec_helper'

RSpec.describe ImageUtil::Codec::ImageMagick do
  before do
    skip 'ImageMagick not available' unless described_class.supported?(:png)
  end

  let(:img) { ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] } }

  it 'encodes and decodes PNG images' do
    data = described_class.encode(:png, img)
    data.start_with?("\x89PNG\r\n\x1a\n".b).should be true

    decoded = described_class.decode(:png, data)
    decoded.dimensions.should == [1, 1]
    decoded[0, 0].should == ImageUtil::Color[255, 0, 0]
  end

  it 'encodes and decodes JPEG images' do
    data = described_class.encode(:jpeg, img)
    data.start_with?("\xFF\xD8".b).should be true

    decoded = described_class.decode(:jpeg, data)
    decoded.dimensions.should == [1, 1]
  end

  it 'handles GIF animations' do
    anim = ImageUtil::Image.new(1, 1, 2) { |_, _, z| ImageUtil::Color[z * 255] }
    data = described_class.encode(:gif, anim)
    decoded = described_class.decode(:gif, data)
    decoded.dimensions.should == [1, 1, 2]
  end

  it 'handles APNG animations' do
    anim = ImageUtil::Image.new(1, 1, 2) { |_, _, z| ImageUtil::Color[z * 255] }
    data = described_class.encode(:apng, anim)
    decoded = described_class.decode(:apng, data)
    decoded.dimensions.should == [1, 1, 2]
  end
end

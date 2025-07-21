require 'spec_helper'
require 'image_util/view'

RSpec.describe ImageUtil::View::Rounded do
  let(:image) { ImageUtil::Image.new(2, 2) { |x,y| ImageUtil::Color[x, y, 0] } }
  let(:view) { described_class.new(image) }

  describe '#[]' do
    it 'rounds coordinates to nearest pixel' do
      view[0.6, 0.2].should == ImageUtil::Color[1,0,0]
    end
  end

  describe '#[]=' do
    it 'writes to the rounded location' do
      img = ImageUtil::Image.new(2, 2) { ImageUtil::Color[0] }
      v = described_class.new(img)
      v[0.4, 0.6] = ImageUtil::Color[5]
      img[0,1].should == ImageUtil::Color[5,5,5,255]
    end
  end
end

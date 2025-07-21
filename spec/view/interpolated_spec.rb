require 'spec_helper'
require 'image_util/view'

RSpec.describe ImageUtil::View::Interpolated do
  let(:image) { ImageUtil::Image.new(2, 2) { |x,y| ImageUtil::Color[x, y, 0] } }
  let(:view) { described_class.new(image) }

  describe '#generate_subpixel_hash' do
    it 'computes weights for fractional locations' do
      hash = view.generate_subpixel_hash([0.2, 0.8])
      hash[[0,0]].should be_within(0.0001).of(0.16)
      hash[[1,0]].should be_within(0.0001).of(0.04)
      hash[[0,1]].should be_within(0.0001).of(0.64)
      hash[[1,1]].should be_within(0.0001).of(0.16)
    end
  end

  describe '#[]' do
    it 'returns bilinear interpolated color' do
      color = view[0.2, 0.8]
      color.r.should be_within(0.001).of(0.2)
      color.g.should be_within(0.001).of(0.8)
    end
  end

  describe '#[]=' do
    it 'distributes color to surrounding pixels' do
      img = ImageUtil::Image.new(2, 2) { ImageUtil::Color[0, 0, 0, 0] }
      v = described_class.new(img)
      v[0.5, 0.5] = ImageUtil::Color[255, 0, 0]
      img[0,0].a.should == 63
      img[1,1].a.should == 63
    end
  end
end

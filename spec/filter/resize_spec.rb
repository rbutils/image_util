require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#resize' do
    it 'creates a new image with given dimensions using provided view' do
      img = described_class.new(1, 1) { ImageUtil::Color[1] }
      out = img.resize(2, 2, view: ImageUtil::View::Rounded)
      out.width.should == 2
      out.height.should == 2
      out[1, 1].should == ImageUtil::Color[1]
      img.width.should == 1
    end

    it 'interpolates pixels with default view' do
      img = described_class.new(2, 2) { |x,y| ImageUtil::Color[x*100, y*100, 0] }
      out = img.resize(3, 3)
      color = out[1,1]
      color.r.should be_within(0.1).of(50)
      color.g.should be_within(0.1).of(50)
    end

    it 'scales images with more than two dimensions' do
      img = described_class.new(1, 1, 2) { |_, _, z| ImageUtil::Color[z * 100] }
      out = img.resize(1, 1, 3)
      out.dimensions.should == [1, 1, 3]
      out[0, 0, 1].r.should be_within(0.1).of(50)
    end
  end
end

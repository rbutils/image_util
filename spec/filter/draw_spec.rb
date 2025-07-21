require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#draw_function!' do
    it 'plots values using provided block' do
      img = described_class.new(3,3) { ImageUtil::Color[0] }
      img.draw_function!(ImageUtil::Color[1], 0..2, axis: :x, draw_axis: :y, view: ImageUtil::View::Rounded) { |x| x }
      img[0,0].should == ImageUtil::Color[1]
      img[1,1].should == ImageUtil::Color[1]
      img[2,2].should == ImageUtil::Color[1]
    end
  end

  describe '#draw_line!' do
    it 'draws a line between two points' do
      img = described_class.new(3,3) { ImageUtil::Color[0] }
      img.draw_line!([0,0], [2,2], ImageUtil::Color[2], view: ImageUtil::View::Rounded)
      img[1,1].should == ImageUtil::Color[2]
    end
  end
end

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

    it 'infers draw axis and limit end' do
      img = described_class.new(3,3) { ImageUtil::Color[0] }
      img.draw_function!(ImageUtil::Color[2], 0.., axis: :y, view: ImageUtil::View::Rounded) { |y| y }
      img[0,0].should == ImageUtil::Color[2]
      img[1,1].should == ImageUtil::Color[2]
      img[2,2].should == ImageUtil::Color[2]
    end
  end

  describe '#draw_line!' do
    it 'draws a line between two points' do
      img = described_class.new(3,3) { ImageUtil::Color[0] }
      img.draw_line!([0,0], [2,2], ImageUtil::Color[2], view: ImageUtil::View::Rounded)
      img[1,1].should == ImageUtil::Color[2]
    end

    it 'handles lines not starting at the origin' do
      img = described_class.new(5,5) { ImageUtil::Color[0] }
      img.draw_line!([3,2], [4,3], ImageUtil::Color[1], view: ImageUtil::View::Interpolated)
      img[4,3].should == ImageUtil::Color[1]
    end

    it 'handles steep lines' do
      img = described_class.new(3,4) { ImageUtil::Color[0] }
      img.draw_line!([1,0], [2,3], ImageUtil::Color[3], view: ImageUtil::View::Rounded)
      img[2,3].should == ImageUtil::Color[3]
    end
  end

  describe '#draw_circle!' do
    it 'draws a circle using the provided center and radius' do
      img = described_class.new(5,5) { ImageUtil::Color[0] }
      img.draw_circle!([2,2], 1, ImageUtil::Color[3], view: ImageUtil::View::Rounded)
      img[2,3].should == ImageUtil::Color[3]
    end
  end

  describe '#draw_circle' do
    it 'returns new image without modifying original' do
      img = described_class.new(3,3) { ImageUtil::Color[0] }
      dup = img.draw_circle([1,1], 1, ImageUtil::Color[4], view: ImageUtil::View::Rounded)
      dup.should_not equal(img)
      dup[1,2].should == ImageUtil::Color[4]
      img[1,2].should == ImageUtil::Color[0]
    end
  end
end

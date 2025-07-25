require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#redimension!' do
    it 'expands image dimensions and pads with transparency' do
      img = described_class.new(2, 1) { |x, _| ImageUtil::Color[x] }
      img.redimension!(3, 2, 2)
      img.dimensions.should == [3, 2, 2]
      img[0,0,0].should == ImageUtil::Color[0]
      img[1,0,0].should == ImageUtil::Color[1]
      img[2,0,0].should == ImageUtil::Color.new(0,0,0,0)
      img[0,1,0].should == ImageUtil::Color.new(0,0,0,0)
      img[0,0,1].should == ImageUtil::Color.new(0,0,0,0)
    end

    it 'increases height efficiently' do
      img = described_class.new(1, 1) { ImageUtil::Color[1] }
      img.redimension!(1, 2)
      img.dimensions.should == [1, 2]
      img[0,0].should == ImageUtil::Color[1]
      img[0,1].should == ImageUtil::Color.new(0,0,0,0)
    end

    it 'adds a dimension without modifying existing data' do
      img = described_class.new(1, 1) { ImageUtil::Color[1] }
      img.redimension!(1, 1, 2)
      img.dimensions.should == [1, 1, 2]
      img[0,0,0].should == ImageUtil::Color[1]
      img[0,0,1].should == ImageUtil::Color.new(0,0,0,0)
    end

    it 'handles extra dimensions when resizing height' do
      img = described_class.new(2, 2, 2) { |x,y,z| ImageUtil::Color[x + y*10 + z*100] }
      img.redimension!(2, 3, 2)
      img.dimensions.should == [2, 3, 2]
      img[0,0,1].should == ImageUtil::Color[100]
      img[0,2,0].should == ImageUtil::Color.new(0,0,0,0)
    end
  end

  describe '#redimension' do
    it 'returns new image without modifying original' do
      img = described_class.new(2, 1)
      dup = img.redimension(1, 1)
      dup.should_not equal(img)
      dup.dimensions.should == [1, 1]
      img.dimensions.should == [2, 1]
    end
  end
end

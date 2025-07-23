require 'spec_helper'

RSpec.describe ImageUtil::Filter::Palette do
  describe '#palette_reduce!' do
    it 'reduces colors in place' do
      img = ImageUtil::Image.new(4,1) { |x,_| ImageUtil::Color[x*50,0,0] }
      img.palette_reduce!(2)
      img.unique_color_count.should <= 2
    end
  end

  describe '#palette_reduce' do
    it 'returns new image without modifying original' do
      img = ImageUtil::Image.new(2,1) { |x,_| ImageUtil::Color[x*100,0,0] }
      dup = img.palette_reduce(1)
      dup.should_not equal(img)
      img.unique_color_count.should == 2
      dup.unique_color_count.should == 1
    end
  end

  describe ImageUtil::Filter::Palette::ColorOctree do
    let(:octree) { described_class.new }

    it 'converts numbers to bit arrays' do
      octree.number_bits(5).should == [0,0,0,0,0,1,0,1]
    end

    it 'recreates numbers from bit arrays' do
      octree.generate_key([1,0,1]).should == 5
    end

    it 'generates identical keys for optimized and generic paths' do
      color3 = ImageUtil::Color[1,2,3]
      color4 = ImageUtil::Color[1,2,3,4]
      octree.key_array3(color3).should == octree.key_array(color3)
      octree.key_array4(color4).should == octree.key_array(color4)
    end

    it 'builds a tree from colors and lists them back' do
      colors = [ImageUtil::Color[1,0,0], ImageUtil::Color[0,2,0],
                ImageUtil::Color[0,0,3,4]]
      octree.build_from(colors)
      octree.colors.should match_array(colors)
    end
  end
end

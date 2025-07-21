require 'spec_helper'

RSpec.describe ImageUtil::Image do
  describe '#paste!' do
    it 'copies another image in place' do
      base = described_class.new(3, 3) { ImageUtil::Color[0] }
      other = described_class.new(2, 2) { |x, y| ImageUtil::Color[x + y] }
      base.paste!(other, 1, 1)
      base[1,1].should == ImageUtil::Color[0]
      base[2,2].should == ImageUtil::Color[2]
    end

    it 'respects alpha when requested' do
      base = described_class.new(1, 1) { ImageUtil::Color[10, 10, 10] }
      over = described_class.new(1, 1) { ImageUtil::Color[20, 0, 0, 128] }
      base.paste!(over, 0, 0, respect_alpha: true)
      expected = ImageUtil::Color[10, 10, 10] + ImageUtil::Color[20,0,0,128]
      expected = ImageUtil::Color.new(*expected.map(&:to_i))
      base[0,0].should == expected
    end

    it 'pastes a 1d image onto another image' do
      base = described_class.new(3, 1) { ImageUtil::Color[0] }
      line = described_class.new(2) { |loc| ImageUtil::Color[loc.first] }
      base.paste!(line, 1, 0)
      base[1,0].should == ImageUtil::Color[0]
      base[2,0].should == ImageUtil::Color[1]
    end
  end

  describe '#paste' do
    it 'returns new image without modifying original' do
      base = described_class.new(2, 1) { ImageUtil::Color[0] }
      other = described_class.new(1, 1) { ImageUtil::Color[1] }
      dup = base.paste(other, 1, 0)
      dup.should_not equal(base)
      dup[1,0].should == ImageUtil::Color[1]
      base[1,0].should == ImageUtil::Color[0]
    end
  end
end

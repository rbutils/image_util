require 'spec_helper'

RSpec.describe ImageUtil::Image::Buffer do
  let(:buffer) { described_class.new([2, 2], 8, 3) }

  it 'computes offsets correctly' do
    buffer.offset_of(1,1).should == buffer.pixel_bytes*3
  end

  it 'sets and gets values' do
    buffer.set([0,0], [255,0,0])
    buffer.get([0,0]).should == ImageUtil::Color[255,0,0]
  end

  it 'splits last dimension' do
    buffer.set_index(0, [1,2,3])
    buffer.last_dimension_split.first.get([0]).should == ImageUtil::Color[1,2,3]
  end

  it 'raises on invalid color bits' do
    ->{ described_class.new([1,1], 12, 3) }.should raise_error(ArgumentError)
  end

  it 'raises on wrong offset dimensions' do
    ->{ buffer.offset_of(0,0,0) }.should raise_error(ArgumentError)
  end

  it 'duplicates buffer correctly' do
    duped = buffer.dup
    buffer.set([0,0], [1,2,3])
    duped.get([0,0]).should == ImageUtil::Color[0,0,0]
  end

  it 'supports 16 and 32 bit buffers' do
    buf16 = described_class.new([1,1], 16, 3)
    buf16.color_bytes.should == 2
    buf16.set([0,0], [1,2,3])
    buf16.get([0,0]).should == ImageUtil::Color[1,2,3]

    buf32 = described_class.new([1,1], 32, 3)
    buf32.color_bytes.should == 4
    buf32.set([0,0], [1,2,3])
    buf32.get([0,0]).should == ImageUtil::Color[1,2,3]
  end
end

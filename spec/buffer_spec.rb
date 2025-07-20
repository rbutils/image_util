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
end

require 'spec_helper'

RSpec.describe ImageUtil::Color do
  it 'parses hex strings' do
    color = ImageUtil::Color['#ff00aa']
    color.r.should == 255
    color.g.should == 0
    color.b.should == 170
    color.a.should == 255
  end

  it 'clamps float components' do
    ImageUtil::Color.component_from_number(1.2).should == 255
  end

  it 'handles buffers with 16 bit depth' do
    color = ImageUtil::Color[1, 2, 3]
    buf = color.to_buffer(16, 3)
    ImageUtil::Color.from_buffer(buf, 16).should == color
  end

  it 'inspects to hex' do
    ImageUtil::Color[255,0,255,128].inspect.should == '#ff00ff80'
  end

  it 'converts from integers and symbols' do
    ImageUtil::Color.from(100).should == ImageUtil::Color[100,100,100]
    ImageUtil::Color[:red].should == ImageUtil::Color[255,0,0]
  end

  it 'compares colors with implicit alpha as equal' do
    ImageUtil::Color[1,2,3].should == ImageUtil::Color[1,2,3,255]
  end

  it 'does not default rgb components' do
    ImageUtil::Color[1,2].should_not == ImageUtil::Color[1,2,0]
  end

  it 'compares alpha channel when present' do
    ImageUtil::Color[1,2,3,128].should_not == ImageUtil::Color[1,2,3]
  end

  it 'raises on bad array values' do
    ->{ ImageUtil::Color.from([Object.new]) }.should raise_error(ArgumentError)
  end
end

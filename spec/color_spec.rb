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

  it 'returns nil for nil components' do
    ImageUtil::Color.component_from_number(nil).should be_nil
  end

  it 'handles buffers with 16 bit depth' do
    color = ImageUtil::Color[1, 2, 3]
    buf = color.to_buffer(16, 3)
    ImageUtil::Color.from_buffer(buf, 16).should == color
  end

  it 'handles 32 bit buffers' do
    color = ImageUtil::Color[1, 2, 3, 4]
    buf = color.to_buffer(32, 4)
    ImageUtil::Color.from_buffer(buf, 32).should == color
  end

  it 'inspects to hex' do
    ImageUtil::Color[255,0,255,128].inspect.should == '#ff00ff80'
  end

  it 'parses short and long hex strings' do
    ImageUtil::Color['#abc'].should == ImageUtil::Color[170,187,204]
    ImageUtil::Color['#01020304'].should == ImageUtil::Color[1,2,3,4]
  end

  it 'converts from integers and symbols' do
    ImageUtil::Color.from(100).should == ImageUtil::Color[100,100,100]
    ImageUtil::Color[:red].should == ImageUtil::Color[255,0,0]
    ImageUtil::Color[:blue].should == ImageUtil::Color[0,0,255]
  end

  it 'clamps negative numbers' do
    ImageUtil::Color.from(-5).should == ImageUtil::Color[0,0,0]
  end

  it 'handles floats' do
    expected = ImageUtil::Color.new(127.5,127.5,127.5)
    ImageUtil::Color.from(0.5).should == expected
  end

  it 'raises on bad string values' do
    ->{ ImageUtil::Color.from("garbage") }.should raise_error(ArgumentError)
  end

  it 'returns itself when given a Color' do
    c = ImageUtil::Color[1,2,3]
    ImageUtil::Color.from(c).object_id.should == c.object_id
  end

  it 'compares colors with implicit alpha as equal' do
    ImageUtil::Color[1,2,3].should == ImageUtil::Color[1,2,3,255]
  end

  it 'compares using eql?' do
    ImageUtil::Color[1,2,3].eql?(ImageUtil::Color[1,2,3,255]).should be true
  end

  it 'returns false for unconvertible comparisons' do
    (ImageUtil::Color[1,2,3] == Object.new).should be false
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

  it 'overlays colors with +' do
    base = ImageUtil::Color[0, 0, 255]
    overlay = ImageUtil::Color[255, 0, 0, 128]
    (base + overlay).should == ImageUtil::Color[128, 0, 127, 255]
  end
end

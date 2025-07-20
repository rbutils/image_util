require 'spec_helper'

RSpec.describe ImageUtil::Image do
  it 'sets and gets pixel values' do
    img = described_class.new(2,2) { |x,y| ImageUtil::Color[x+y, x+y, x+y] }
    img[0,0].should == ImageUtil::Color[0,0,0]
    img[1,0].should == ImageUtil::Color[1,1,1]
  end

  it 'extracts subimages' do
    img = described_class.new(2,2) { |x,y| ImageUtil::Color[x,y,0] }
    sub = img[0..0, 0..0]
    sub.dimensions.should == [1,1]
    sub[0,0].should == ImageUtil::Color[0,0,0]
  end

  it 'converts to pam' do
    img = described_class.new(1,1) { |_| ImageUtil::Color[1,2,3] }
    img.to_pam.lines.first.chomp.should == 'P7'
  end

  it 'raises when to_pam called on 3D image' do
    img = described_class.new(1,1,1)
    -> { img.to_pam }.should raise_error(ArgumentError)
  end

  it 'raises when color length is invalid' do
    img = described_class.new(1,1, color_length: 1)
    -> { img.to_pam }.should raise_error(ArgumentError)
  end

  it 'iterates over pixels' do
    img = described_class.new(2,1) { |x,y| ImageUtil::Color[x] }
    pixels = []
    img.each_pixel { |c| pixels << c.r }
    pixels.should == [0,1]
  end

  it 'fills all pixels with one color' do
    img = described_class.new(2,1)
    img.all = ImageUtil::Color[1,2,3]
    img[0,0].should == ImageUtil::Color[1,2,3]
    img[1,0].should == ImageUtil::Color[1,2,3]
  end

  it 'raises on out-of-bounds access' do
    img = described_class.new(1,1)
    -> { img[2,0] }.should raise_error(IndexError)
  end

  it 'assigns images at a location' do
    base = described_class.new(3,3) { ImageUtil::Color[0] }
    other = described_class.new(2,2) { |x,y| ImageUtil::Color[x+y] }
    base[1,1] = other
    base[1,1].should == ImageUtil::Color[0]
    base[2,2].should == ImageUtil::Color[2]
  end

  it 'ignores pixels outside bounds when assigning' do
    base = described_class.new(3,3) { ImageUtil::Color[0] }
    other = described_class.new(2,2) { ImageUtil::Color[1] }
    base[2,2] = other
    base[2,2].should == ImageUtil::Color[1]
  end

  it 'handles each_pixel_location' do
    img = described_class.new(2,2) { ImageUtil::Color[0] }
    locs = []
    img.each_pixel_location([0..1, 1]) { |l| locs << l }
    locs.should == [[0,1],[1,1]]
  end

  it 'sets pixels using set_each_pixel_by_location' do
    img = described_class.new(2,1)
    img.set_each_pixel_by_location { |loc| ImageUtil::Color[loc.first] }
    img[1,0].should == ImageUtil::Color[1,1,1]
  end

  it 'expands locations with nil bounds' do
    img = described_class.new(2,2)
    counts, locs = img.location_expand([nil..1, 0..nil])
    counts.should == [2,2]
    locs.length.should == 4
  end

  it 'creates nested arrays via deep_to_a' do
    img = described_class.new(1,2) { |_,y| ImageUtil::Color[y] }
    arr = img.deep_to_a
    arr.should == [[ImageUtil::Color[0]], [ImageUtil::Color[1]]]
  end

  it 'fills to height in pam' do
    img = described_class.new(1,1) { ImageUtil::Color[0] }
    pam = img.to_pam(fill_to: 6)
    pam.lines[2].should include('HEIGHT 6')
  end

  it 'converts to sixel without external tools' do
    img = described_class.new(1,1) { ImageUtil::Color[255,0,0] }
    sixel = img.to_sixel
    sixel.start_with?("\ePq\"1;1;1;1#0;2;0;0;0;4#1;2;100;0;0").should be true
    sixel.end_with?("\e\\").should be true
  end
end

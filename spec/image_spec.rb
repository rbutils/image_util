require 'spec_helper'

RSpec.describe ImageUtil::Image do
  it 'sets and gets pixel values' do
    img = described_class.new(2,2) { |x,y| ImageUtil::Color[x+y, x+y, x+y, 255] }
    img[0,0].should == ImageUtil::Color[0,0,0,255]
    img[1,0].should == ImageUtil::Color[1,1,1,255]
  end

  it 'extracts subimages' do
    img = described_class.new(2,2) { |x,y| ImageUtil::Color[x,y,0,255] }
    sub = img[0..0, 0..0]
    sub.dimensions.should == [1,1]
    sub[0,0].should == ImageUtil::Color[0,0,0,255]
  end

  it 'converts to pam' do
    img = described_class.new(1,1) { |_| ImageUtil::Color[1,2,3] }
    img.to_pam.lines.first.chomp.should == 'P7'
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
    img[0,0].should == ImageUtil::Color[1,2,3,255]
    img[1,0].should == ImageUtil::Color[1,2,3,255]
  end

  it 'raises on out-of-bounds access' do
    img = described_class.new(1,1)
    -> { img[2,0] }.should raise_error(IndexError)
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
    img[1,0].should == ImageUtil::Color[1,1,1,255]
  end

  it 'fills to height in pam' do
    img = described_class.new(1,1) { ImageUtil::Color[0] }
    pam = img.to_pam(fill_to: 6)
    pam.lines[2].should include('HEIGHT 6')
  end
end

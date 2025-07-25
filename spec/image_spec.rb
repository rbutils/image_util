require 'spec_helper'
require 'tempfile'
require 'tmpdir'

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
    img = described_class.new(1,1, channels: 1)
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

  it 'resizes images when assigning to ranges' do
    base = described_class.new(3,3) { ImageUtil::Color[0] }
    other = described_class.new(1,1) { ImageUtil::Color[5] }
    base[1..2, 1..2] = other
    base[1,1].should == ImageUtil::Color[5]
    base[2,2].should == ImageUtil::Color[5]
  end

  it 'handles each_pixel_location' do
    img = described_class.new(2,2) { ImageUtil::Color[0] }
    locs = []
    img.each_pixel_location([0..1, 1]) { |l| locs << l }
    locs.should == [[0,1],[1,1]]
  end

  it 'sets pixels using set_each_pixel_by_location!' do
    img = described_class.new(2,1)
    img.set_each_pixel_by_location! { |loc| ImageUtil::Color[loc.first] }
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

  it 'encodes 1D images to pam' do
    img = described_class.new(2) { |x| ImageUtil::Color[x] }
    pam = img.to_pam
    pam.lines[2].should include('HEIGHT 1')
  end

  it 'converts to string and back' do
    img = described_class.new(1,1) { ImageUtil::Color[1,2,3] }
    str = img.to_string(:pam)
    other = described_class.from_string(str, :pam)
    other[0,0].should == ImageUtil::Color[1,2,3,255]
  end

  it 'infers format from string' do
    img = described_class.new(1,1) { ImageUtil::Color[9,8,7] }
    str = img.to_string(:pam)
    other = described_class.from_string(str)
    other[0,0].should == ImageUtil::Color[9,8,7,255]
  end

  it 'writes to and reads from files' do
    img = described_class.new(1,1) { ImageUtil::Color[4,5,6] }
    Tempfile.create('img') do |f|
      img.to_file(f, :pam)
      f.rewind
      other = described_class.from_file(f, :pam)
      other[0,0].should == ImageUtil::Color[4,5,6,255]
    end
  end

  it 'handles file paths' do
    img = described_class.new(1,1) { ImageUtil::Color[7,8,9] }
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'tmp.pam')
      img.to_file(path, :pam)
      other = described_class.from_file(path, :pam)
      other[0,0].should == ImageUtil::Color[7,8,9,255]
    end
  end

  it 'infers format from file' do
    img = described_class.new(1,1) { ImageUtil::Color[6,5,4] }
    Tempfile.create('img') do |f|
      img.to_file(f, :pam)
      f.rewind
      other = described_class.from_file(f)
      other[0,0].should == ImageUtil::Color[6,5,4,255]
    end
  end

  it 'handles pipes when detecting format' do
    img = described_class.new(1,1) { ImageUtil::Color[3,2,1] }
    Tempfile.create('img') do |f|
      img.to_file(f, :pam)
      f.rewind
      IO.popen(['cat', f.path]) do |io|
        other = described_class.from_file(io)
        other[0,0].should == ImageUtil::Color[3,2,1,255]
      end
    end
  end

  describe '#view' do
    it 'yields view and returns self' do
      img = described_class.new(1,1)
      result = img.view(ImageUtil::View::Rounded) do |v|
        v.should be_a(ImageUtil::View::Rounded)
      end
      result.should equal(img)
    end

    it 'returns view object without block' do
      img = described_class.new(1,1)
      v = img.view(ImageUtil::View::Rounded)
      v.should be_a(ImageUtil::View::Rounded)
    end
  end

  it 'respects preferred codec' do
    img = described_class.new(1,1)
    img.to_string(:pam, codec: :Pam).lines.first.chomp.should == 'P7'
  end

  it 'raises when preferred codec is unsuitable' do
    img = described_class.new(1,1)
    -> { img.to_string(:pam, codec: :RubySixel) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'raises when format cannot be detected from string' do
    -> { described_class.from_string("garbage") }.should raise_error(ArgumentError)
  end

  it 'raises when format cannot be detected from file' do
    Tempfile.create("img") do |f|
      f.write("garbage")
      f.rewind
      -> { described_class.from_file(f) }.should raise_error(ArgumentError)
    end
  end
end

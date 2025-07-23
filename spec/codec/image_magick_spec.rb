require 'spec_helper'

RSpec.describe ImageUtil::Codec::ImageMagick do
  let(:img) { ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] } }
  let(:pam) { ImageUtil::Codec::Pam.encode(:pam, img) }

  before do
    allow(described_class).to receive(:magick_available?).and_return(true)
  end

  it 'encodes using ImageMagick' do
    proc_io = StringIO.new
    def proc_io.close_write; end
    def proc_io.read; 'OUT' end
    allow(IO).to receive(:popen).and_yield(proc_io)

    out = described_class.encode(:png, img)
    out.should == 'OUT'
    proc_io.string.bytes.should == pam.bytes
  end

  it 'encodes JPEG' do
    proc_io = StringIO.new
    def proc_io.close_write; end
    def proc_io.read; 'JOUT' end
    allow(IO).to receive(:popen).and_yield(proc_io)

    out = described_class.encode(:jpeg, img)
    out.should == 'JOUT'
    proc_io.string.bytes.should == pam.bytes
  end

  it 'encodes GIF animation' do
    anim = ImageUtil::Image.new(1, 1, 2) { |_, _, z| ImageUtil::Color[z * 255] }
    frame0 = ImageUtil::Codec::Pam.encode(:pam, ImageUtil::Image.from_buffer(anim.buffer.last_dimension_split[0]))
    frame1 = ImageUtil::Codec::Pam.encode(:pam, ImageUtil::Image.from_buffer(anim.buffer.last_dimension_split[1]))

    proc_io = StringIO.new
    def proc_io.read; 'GOUT' end
    allow(IO).to receive(:popen).and_yield(proc_io)

    out = described_class.encode(:gif, anim)
    out.should == 'GOUT'
    proc_io.string.bytes.should == (frame0 + frame1).bytes
  end

  it 'decodes using ImageMagick' do
    proc_io = StringIO.new(pam)
    def proc_io.close_write; end
    def proc_io.<<(_str); end
    allow(IO).to receive(:popen).and_yield(proc_io)

    decoded = described_class.decode(:png, 'PNG')
    decoded.dimensions.should == [1, 1]
  end

  it 'decodes JPEG' do
    proc_io = StringIO.new(pam)
    def proc_io.close_write; end
    def proc_io.<<(_str); end
    allow(IO).to receive(:popen).and_yield(proc_io)

    decoded = described_class.decode(:jpeg, 'JPG')
    decoded.dimensions.should == [1, 1]
  end

  it 'decodes animated GIF' do
    frame = ImageUtil::Image.new(1, 1) { ImageUtil::Color[0] }
    pam0 = ImageUtil::Codec::Pam.encode(:pam, frame)
    pam1 = ImageUtil::Codec::Pam.encode(:pam, frame)
    proc_io = StringIO.new(pam0 + pam1)
    def proc_io.close_write; end
    def proc_io.<<(_str); end
    IO.should_receive(:popen).with(["magick", "gif:-", "-coalesce", "pam:-"], "r+").and_yield(proc_io)

    decoded = described_class.decode(:gif, 'GIF')
    decoded.dimensions.should == [1, 1, 2]
  end

  it 'decodes animated PNG' do
    frame = ImageUtil::Image.new(1, 1) { ImageUtil::Color[0] }
    pam0 = ImageUtil::Codec::Pam.encode(:pam, frame)
    pam1 = ImageUtil::Codec::Pam.encode(:pam, frame)
    proc_io = StringIO.new(pam0 + pam1)
    def proc_io.close_write; end
    def proc_io.<<(_str); end
    IO.should_receive(:popen).with(["magick", "apng:-", "-coalesce", "pam:-"], "r+").and_yield(proc_io)

    decoded = described_class.decode(:apng, 'APNG')
    decoded.dimensions.should == [1, 1, 2]
  end
end

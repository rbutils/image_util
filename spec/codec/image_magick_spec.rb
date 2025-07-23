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

  it 'decodes using ImageMagick' do
    proc_io = StringIO.new
    def proc_io.close_write; end
    pam_str = pam
    proc_io.define_singleton_method(:read) { pam_str }
    allow(IO).to receive(:popen).and_yield(proc_io)

    decoded = described_class.decode(:png, 'PNG')
    decoded.dimensions.should == [1, 1]
    proc_io.string.should == 'PNG'
  end

  it 'decodes JPEG' do
    proc_io = StringIO.new
    def proc_io.close_write; end
    pam_str = pam
    proc_io.define_singleton_method(:read) { pam_str }
    allow(IO).to receive(:popen).and_yield(proc_io)

    decoded = described_class.decode(:jpeg, 'JPG')
    decoded.dimensions.should == [1, 1]
    proc_io.string.should == 'JPG'
  end

  it 'returns false for unsupported format' do
    described_class.supported?(:foo).should be false
  end

  context 'when ImageMagick is not available' do
    before do
      allow(described_class).to receive(:magick_available?).and_call_original
      described_class.instance_variable_set(:@magick_available, nil)
      allow(described_class).to receive(:system).and_return(false)
    end

    it 'reports unsupported for any format' do
      described_class.supported?(:png).should be false
      described_class.supported?(nil).should be false
    end
  end
end

require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libsixel do
  before do
    described_class.const_set(:AVAILABLE, true)
    allow(described_class).to receive(:sixel_output_new) do |ptr, writer, _a, _b|
      ptr.write_pointer(FFI::MemoryPointer.new(:pointer))
      @writer = writer
      0
    end
    allow(described_class).to receive(:sixel_dither_new) do |ptr, _a, _b|
      ptr.write_pointer(FFI::MemoryPointer.new(:pointer))
      0
    end
    allow(described_class).to receive(:sixel_dither_initialize).and_return(0)
    allow(described_class).to receive(:sixel_dither_set_diffusion_type)
    allow(described_class).to receive(:sixel_encode) do |_buf, _w, _h, _fmt, _d, _o|
      data = "\ePqEND\e\\"
      ptr = FFI::MemoryPointer.from_string(data)
      @writer.call(ptr, data.bytesize, nil)
      0
    end
    allow(described_class).to receive(:sixel_dither_unref)
    allow(described_class).to receive(:sixel_output_unref)
  end

  it 'encodes an image to sixel' do
    img = ImageUtil::Image.new(2, 1) { |x,_| ImageUtil::Color[x * 255, 0, 0] }
    data = described_class.encode(:sixel, img)
    data.start_with?("\ePq").should be true
    data.end_with?("\e\\").should be true
  end

  it 'raises for unsupported format' do
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:foo, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'raises when FFI call fails' do
    allow(described_class).to receive(:sixel_dither_new).and_return(1)
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:sixel, img) }.should raise_error(StandardError)
  end

  it 'raises when output creation fails' do
    allow(described_class).to receive(:sixel_output_new).and_return(1)
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:sixel, img) }.should raise_error(StandardError)
  end

  it 'raises when dither initialize fails' do
    allow(described_class).to receive(:sixel_dither_initialize).and_return(1)
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:sixel, img) }.should raise_error(StandardError)
  end

  it 'raises when encode fails' do
    allow(described_class).to receive(:sixel_encode).and_return(1)
    img = ImageUtil::Image.new(1,1)
    ->{ described_class.encode(:sixel, img) }.should raise_error(StandardError)
  end

  context 'when library is unavailable' do
    before { described_class.const_set(:AVAILABLE, false) }

    it 'reports unsupported' do
      described_class.supported?(:sixel).should be false
      img = ImageUtil::Image.new(1,1)
      -> { described_class.encode(:sixel, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    end
  end
end

require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libpng do
  before do
    described_class.const_set(:AVAILABLE, true)
    allow(described_class).to receive(:png_image_write_to_memory) do |img, out_ptr, size_ptr, *_|
      header = "\x89PNG\r\n\x1a\n".b
      size_ptr.write_ulong(header.bytesize)
      out_ptr&.put_bytes(0, header)
      1
    end
    allow(described_class).to receive(:png_image_begin_read_from_memory) do |img, data_ptr, size|
      img[:width] = 2
      img[:height] = 1
      1
    end
    allow(described_class).to receive(:png_image_finish_read) do |img, _ptr, buf_ptr, row_stride, _|
      # two pixels: [0,0,0,255] and [1,0,0,255]
      pixels = "\x00\x00\x00\xff\x01\x00\x00\xff"
      buf_ptr.put_bytes(0, pixels)
      1
    end
    allow(described_class).to receive(:png_image_free)
  end

  it 'encodes and decodes a PNG image' do
    img = ImageUtil::Image.new(2, 1) { |x, _y| ImageUtil::Color[x, 0, 0] }
    data = described_class.encode(:png, img)
    data.start_with?("\x89PNG\r\n\x1a\n".b).should be true

    decoded = described_class.decode(:png, data)
    decoded.dimensions.should == [2, 1]
    decoded[1, 0].should == ImageUtil::Color[1, 0, 0]
  end

  it 'raises for unsupported color depth' do
    img = ImageUtil::Image.new(1, 1, color_bits: 16)
    -> { described_class.encode(:png, img) }.should raise_error(ArgumentError)
  end
end

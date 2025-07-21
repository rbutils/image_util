require 'spec_helper'

RSpec.describe ImageUtil::Codec::Libturbojpeg do
  let(:img) { ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] } }

  context 'when library is unavailable' do
    before do
      stub_const("#{described_class.name}::AVAILABLE", false)
    end

    it 'raises on encode' do
      -> { described_class.encode(:jpeg, img) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    end

    it 'raises on decode' do
      -> { described_class.decode(:jpeg, 'data') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    end
  end

  context 'with stubbed FFI' do
    before do
      stub_const("#{described_class.name}::AVAILABLE", true)
      allow(described_class).to receive(:tjInitCompress).and_return(FFI::Pointer.new(1))
      allow(described_class).to receive(:tjInitDecompress).and_return(FFI::Pointer.new(1))
      allow(described_class).to receive(:tjDestroy)
      allow(described_class).to receive(:tjFree)
      allow(described_class).to receive(:tjCompress2) do |*args|
        ptrptr = args[6]
        sizeptr = args[7]
        jpeg = 'JPEG'
        mem = FFI::MemoryPointer.from_string(jpeg)
        ptrptr.write_pointer(mem)
        sizeptr.write_ulong(jpeg.bytesize)
        0
      end
      allow(described_class).to receive(:tjDecompressHeader3) do |*args|
        wptr = args[3]
        hptr = args[4]
        wptr.write_int(1)
        hptr.write_int(1)
        0
      end
      allow(described_class).to receive(:tjDecompress2) do |*args|
        dst = args[3]
        w = args[4]
        h = args[6]
        dst.put_bytes(0, "\x00" * w * h * 4)
        0
      end
      stub_const("#{described_class.name}::DECOMPRESS_HEADER_FUNC", :tjDecompressHeader3)
    end

    it 'encodes and decodes a JPEG image' do
      data = described_class.encode(:jpeg, img)
      data.should == 'JPEG'

      decoded = described_class.decode(:jpeg, data)
      decoded.dimensions.should == [1, 1]
    end

    it 'raises for unsupported color depth' do
      bad = ImageUtil::Image.new(1, 1, color_bits: 16)
      -> { described_class.encode(:jpeg, bad) }.should raise_error(ArgumentError)
    end
  end
end

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
      # rubocop:disable Naming/MethodName
      described_class.define_singleton_method(:tjInitCompress) { FFI::Pointer.new(1) }
      described_class.define_singleton_method(:tjInitDecompress) { FFI::Pointer.new(1) }
      described_class.define_singleton_method(:tjDestroy) { |_ptr| }
      described_class.define_singleton_method(:tjFree) { |_ptr| }
      # rubocop:disable Metrics/ParameterLists
      described_class.define_singleton_method(:tjCompress2) do |_handle, _src, _w, _pitch, _h, _fmt, ptrptr, sizeptr, *_|
        jpeg = 'JPEG'
        mem = FFI::MemoryPointer.from_string(jpeg)
        ptrptr.write_pointer(mem)
        sizeptr.write_ulong(jpeg.bytesize)
        0
      end
      described_class.define_singleton_method(:tjDecompressHeader3) do |_h, _buf, _size, wptr, hptr, *_|
        wptr.write_int(1)
        hptr.write_int(1)
        0
      end
      described_class.define_singleton_method(:tjDecompress2) do |_h, _buf, _size, dst, w, _p, h, _fmt, _|
        dst.put_bytes(0, "\x00" * w * h * 4)
        0
      end
      described_class.const_set(:DECOMPRESS_HEADER_FUNC, :tjDecompressHeader3)
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Naming/MethodName
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

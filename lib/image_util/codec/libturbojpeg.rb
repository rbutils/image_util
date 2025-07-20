# frozen_string_literal: true

module ImageUtil
  module Codec
    # rubocop:disable Metrics/ModuleLength
    module Libturbojpeg
      SUPPORTED_FORMATS = %i[jpeg jpg].freeze

      begin
        require "ffi"

        extend FFI::Library
        ffi_lib [
          "libturbojpeg.so.0", # Linux
          "libturbojpeg.so", "libturbojpeg", # generic
          "turbojpeg.dll", "libturbojpeg.dll", # Windows
          "libturbojpeg.dylib", "turbojpeg.dylib" # macOS
        ]

        AVAILABLE = true
      rescue LoadError
        AVAILABLE = false
      end

      TJPF_RGB  = 0
      TJPF_RGBA = 7

      if AVAILABLE
        attach_function :tjInitCompress, [], :pointer
        attach_function :tjInitDecompress, [], :pointer
        attach_function :tjCompress2,
                        %i[pointer pointer int int int int pointer pointer int int int],
                        :int

        begin
          attach_function :tjDecompressHeader3,
                          %i[pointer pointer ulong pointer pointer pointer pointer],
                          :int
          DECOMPRESS_HEADER_FUNC = :tjDecompressHeader3
        rescue FFI::NotFoundError
          attach_function :tjDecompressHeader2,
                          %i[pointer pointer ulong pointer pointer pointer],
                          :int
          DECOMPRESS_HEADER_FUNC = :tjDecompressHeader2
        end

        attach_function :tjDecompress2,
                        %i[pointer pointer ulong pointer int int int int int],
                        :int
        attach_function :tjDestroy, [:pointer], :int
        attach_function :tjFree, [:pointer], :void
      end

      module_function

      def supported?(format = nil)
        return false unless AVAILABLE

        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(_format, image, quality: 75)
        raise UnsupportedFormatError, "libturbojpeg not available" unless AVAILABLE

        unless image.is_a?(Image)
          raise ArgumentError, "image must be an ImageUtil::Image"
        end

        unless image.dimensions.length == 2
          raise ArgumentError, "only 2D images supported"
        end

        unless image.color_bits == 8
          raise ArgumentError, "only 8-bit colors supported"
        end

        fmt = image.color_length == 4 ? TJPF_RGBA : TJPF_RGB

        handle = tjInitCompress
        raise StandardError, "tjInitCompress failed" if handle.null?

        src_ptr = FFI::MemoryPointer.from_string(image.buffer.get_string)
        jpeg_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        jpeg_size_ptr = FFI::MemoryPointer.new(:ulong)

        res = tjCompress2(handle, src_ptr, image.width, 0, image.height, fmt, jpeg_ptr_ptr, jpeg_size_ptr, 0, quality, 0)
        raise StandardError, "compression failed" if res != 0

        jpeg_ptr = jpeg_ptr_ptr.read_pointer
        jpeg_size = jpeg_size_ptr.read_ulong
        data = jpeg_ptr.read_string(jpeg_size)
        tjFree(jpeg_ptr)
        data
      ensure
        tjDestroy(handle) if handle && !handle.null?
      end

      def encode_io(format, image, io, **kwargs)
        io << encode(format, image, **kwargs)
      end

      def decode(_format, data)
        raise UnsupportedFormatError, "libturbojpeg not available" unless AVAILABLE

        handle = tjInitDecompress
        raise StandardError, "tjInitDecompress failed" if handle.null?

        jpeg_buf = FFI::MemoryPointer.from_string(data)
        width_ptr = FFI::MemoryPointer.new(:int)
        height_ptr = FFI::MemoryPointer.new(:int)
        subsamp_ptr = FFI::MemoryPointer.new(:int)
        cs_ptr = FFI::MemoryPointer.new(:int)

        header_args = [handle, jpeg_buf, data.bytesize, width_ptr, height_ptr]
        if DECOMPRESS_HEADER_FUNC == :tjDecompressHeader3
          header_args += [subsamp_ptr, cs_ptr]
        else
          header_args << subsamp_ptr
        end
        res = public_send(DECOMPRESS_HEADER_FUNC, *header_args)
        raise StandardError, "header decode failed" if res != 0

        width = width_ptr.read_int
        height = height_ptr.read_int

        dst_ptr = FFI::MemoryPointer.new(:uchar, width * height * 4)
        res = tjDecompress2(handle, jpeg_buf, data.bytesize, dst_ptr, width, 0, height, TJPF_RGBA, 0)
        raise StandardError, "decompress failed" if res != 0

        raw = dst_ptr.read_string(width * height * 4)
        io_buf = IO::Buffer.for(raw)
        buf = Image::Buffer.new([width, height], 8, 4, io_buf)
        Image.from_buffer(buf)
      ensure
        tjDestroy(handle) if handle && !handle.null?
      end

      def decode_io(format, io)
        decode(format, io.read)
      end

      Codec.register(:jpeg, self)
      Codec.register(:jpg, self)
    end
    # rubocop:enable Metrics/ModuleLength
  end
end

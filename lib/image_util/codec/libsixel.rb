# frozen_string_literal: true

module ImageUtil
  module Codec
    module Libsixel
      SUPPORTED_FORMATS = [:sixel].freeze

      # https://github.com/libsixel/libsixel
      SIXEL_PALETTE_MAX = 256
      SIXEL_LARGE_AUTO = 0
      SIXEL_REP_AUTO = 0
      SIXEL_QUALITY_AUTO = 0
      SIXEL_DIFFUSE_AUTO = 0
      SIXEL_PIXELFORMAT_RGB888   = 3
      SIXEL_PIXELFORMAT_RGBA8888 = 0x11

      extend Guard

      begin
        require "ffi"

        extend FFI::Library
        ffi_lib [
          "libsixel.so.1", # Linux
          "libsixel-1.dll", "libsixel.dll", # Windows
          "libsixel.1.dylib", "libsixel.dylib", # macOS
          "libsixel.so", "libsixel"
        ]

        callback :write_function, %i[pointer int pointer], :int

        attach_function :sixel_output_new, %i[pointer write_function pointer pointer], :int
        attach_function :sixel_output_unref, [:pointer], :void
        attach_function :sixel_dither_new, %i[pointer int pointer], :int
        attach_function :sixel_dither_initialize, %i[pointer pointer int int int int int int], :int
        attach_function :sixel_dither_set_diffusion_type, %i[pointer int], :void
        attach_function :sixel_dither_unref, [:pointer], :void
        attach_function :sixel_encode, %i[pointer int int int pointer pointer], :int

        AVAILABLE = true
      rescue LoadError
        AVAILABLE = false
      end

      module_function

      def supported?(format = nil)
        return false unless AVAILABLE

        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        raise UnsupportedFormatError, "libsixel not available" unless AVAILABLE

        guard_2d_image!(image)
        guard_8bit_colors!(image)

        fmt = image.color_length == 4 ? SIXEL_PIXELFORMAT_RGBA8888 : SIXEL_PIXELFORMAT_RGB888

        data = "".b
        writer = FFI::Function.new(:int, %i[pointer int pointer]) do |ptr, size, _|
          data << ptr.read_string(size)
          size
        end

        out_ptr = FFI::MemoryPointer.new(:pointer)
        res = sixel_output_new(out_ptr, writer, nil, nil)
        raise StandardError, "sixel_output_new failed" if res != 0

        output = out_ptr.read_pointer

        dither_ptr = FFI::MemoryPointer.new(:pointer)
        res = sixel_dither_new(dither_ptr, -1, nil)
        raise StandardError, "sixel_dither_new failed" if res != 0

        dither = dither_ptr.read_pointer

        pixels = image.buffer.get_string
        buf_ptr = FFI::MemoryPointer.new(:uchar, pixels.bytesize)
        buf_ptr.put_bytes(0, pixels)

        res = sixel_dither_initialize(
          dither,
          buf_ptr,
          image.width,
          image.height,
          fmt,
          SIXEL_LARGE_AUTO,
          SIXEL_REP_AUTO,
          SIXEL_QUALITY_AUTO
        )
        raise StandardError, "sixel_dither_initialize failed" if res != 0

        sixel_dither_set_diffusion_type(dither, SIXEL_DIFFUSE_AUTO)

        res = sixel_encode(buf_ptr, image.width, image.height, fmt, dither, output)
        raise StandardError, "sixel_encode failed" if res != 0

        data
      ensure
        sixel_dither_unref(dither) if defined?(dither) && dither && !dither.null?
        sixel_output_unref(output) if defined?(output) && output && !output.null?
      end

      def encode_io(format, image, io)
        io << encode(format, image)
      end

      def decode(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end

      def decode_io(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end
    end
  end
end

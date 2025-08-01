# frozen_string_literal: true

module ImageUtil
  module Codec
    module Libpng
      SUPPORTED_FORMATS = [:png].freeze

      extend Guard

      begin
        require "ffi"

        extend FFI::Library
        ffi_lib [
          "libpng16.so.16", # Linux
          "libpng16-16.dll", "libpng16.dll", # Windows
          "libpng16.16.dylib", "libpng16.dylib", # macOS
          "libpng16.so", "libpng.so", "libpng.dll", "libpng.dylib", # generic
          "libpng16", "libpng", "png16", "png"
        ]

        AVAILABLE = true
      rescue LoadError
        AVAILABLE = false
      end

      PNG_IMAGE_VERSION = 1

      PNG_FORMAT_FLAG_ALPHA = 0x01
      PNG_FORMAT_FLAG_COLOR = 0x02
      PNG_FORMAT_FLAG_LINEAR = 0x04

      PNG_FORMAT_RGB  = PNG_FORMAT_FLAG_COLOR
      PNG_FORMAT_RGBA = PNG_FORMAT_FLAG_COLOR | PNG_FORMAT_FLAG_ALPHA

      if AVAILABLE
        class PngImage < FFI::Struct
          layout :opaque, :pointer,
                 :version, :uint32,
                 :width, :uint32,
                 :height, :uint32,
                 :format, :uint32,
                 :flags, :uint32,
                 :colormap_entries, :uint32,
                 :warning_or_error, :uint32,
                 :message, [:char, 64]
        end

        attach_function :png_image_write_to_memory, %i[pointer pointer pointer int pointer int pointer], :int
        attach_function :png_image_begin_read_from_memory, %i[pointer pointer size_t], :int
        attach_function :png_image_finish_read, %i[pointer pointer pointer int pointer], :int
        attach_function :png_image_free, [:pointer], :void
      end

      module_function

      def supported?(format = nil)
        return false unless AVAILABLE

        return true if format.nil?

        SUPPORTED_FORMATS.include?(format.to_s.downcase.to_sym)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        raise UnsupportedFormatError, "libpng not available" unless AVAILABLE

        guard_2d_image!(image)
        guard_8bit_colors!(image)

        fmt = if image.channels == 4
                PNG_FORMAT_RGBA
              else
                PNG_FORMAT_RGB
              end

        img = PngImage.new
        img[:version] = PNG_IMAGE_VERSION
        img[:width] = image.width
        img[:height] = image.height
        img[:format] = fmt
        img[:flags] = 0
        img[:colormap_entries] = 0

        row_stride = image.width * image.channels
        buffer_ptr = FFI::MemoryPointer.from_string(image.buffer.get_string)
        size_ptr = FFI::MemoryPointer.new(:size_t)

        ok = png_image_write_to_memory(img, nil, size_ptr, 0, buffer_ptr, row_stride, nil)
        raise StandardError, img[:message].to_s if ok.zero?

        size = size_ptr.read_ulong
        out_ptr = FFI::MemoryPointer.new(:uchar, size)
        ok = png_image_write_to_memory(img, out_ptr, size_ptr, 0, buffer_ptr, row_stride, nil)
        raise StandardError, img[:message].to_s if ok.zero?

        out_ptr.read_string(size_ptr.read_ulong)
      ensure
        png_image_free(img) if img
      end

      def decode(format, data)
        guard_supported_format!(format, SUPPORTED_FORMATS)
        raise UnsupportedFormatError, "libpng not available" unless AVAILABLE

        img = PngImage.new
        img[:version] = PNG_IMAGE_VERSION

        data_ptr = FFI::MemoryPointer.from_string(data)
        ok = png_image_begin_read_from_memory(img, data_ptr, data.bytesize)
        raise StandardError, img[:message].to_s if ok.zero?

        img[:format] = PNG_FORMAT_RGBA
        row_stride = img[:width] * 4
        buffer_ptr = FFI::MemoryPointer.new(:uchar, row_stride * img[:height])

        ok = png_image_finish_read(img, nil, buffer_ptr, row_stride, nil)
        raise StandardError, img[:message].to_s if ok.zero?

        raw = buffer_ptr.read_string(row_stride * img[:height])
        io_buf = IO::Buffer.for(raw)
        buf = Image::Buffer.new([img[:width], img[:height]], 8, 4, io_buf)
        Image.from_buffer(buf)
      ensure
        png_image_free(img) if img
      end
    end
  end
end

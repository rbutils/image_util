module ImageUtil
  module LibPNG
    require "ffi"

    extend FFI::Library
    ffi_lib %w[png16 png libpng16 libpng]

    PNG_IMAGE_VERSION = 1

    PNG_FORMAT_FLAG_ALPHA = 0x01
    PNG_FORMAT_FLAG_COLOR = 0x02
    PNG_FORMAT_FLAG_LINEAR = 0x04

    PNG_FORMAT_RGB  = PNG_FORMAT_FLAG_COLOR
    PNG_FORMAT_RGBA = PNG_FORMAT_FLAG_COLOR | PNG_FORMAT_FLAG_ALPHA

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
end

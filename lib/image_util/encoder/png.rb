require_relative "../libpng"

module ImageUtil
  module Encoder
    module PNG
      module_function

      def encode(image)
        unless image.is_a?(ImageUtil::Image)
          raise ArgumentError, "image must be an ImageUtil::Image"
        end

        unless image.dimensions.length == 2
          raise ArgumentError, "only 2D images supported"
        end

        unless image.color_bits == 8
          raise ArgumentError, "only 8-bit colors supported"
        end

        fmt = if image.color_length == 4
                LibPNG::PNG_FORMAT_RGBA
              else
                LibPNG::PNG_FORMAT_RGB
              end

        img = LibPNG::PngImage.new
        img[:version] = LibPNG::PNG_IMAGE_VERSION
        img[:width] = image.width
        img[:height] = image.height
        img[:format] = fmt
        img[:flags] = 0
        img[:colormap_entries] = 0

        row_stride = image.width * image.color_length
        buffer_ptr = FFI::MemoryPointer.from_string(image.buffer.get_string)
        size_ptr = FFI::MemoryPointer.new(:size_t)

        ok = LibPNG.png_image_write_to_memory(img, nil, size_ptr, 0, buffer_ptr, row_stride, nil)
        raise StandardError, img[:message].to_s if ok.zero?

        size = size_ptr.read_ulong
        out_ptr = FFI::MemoryPointer.new(:uchar, size)
        ok = LibPNG.png_image_write_to_memory(img, out_ptr, size_ptr, 0, buffer_ptr, row_stride, nil)
        raise StandardError, img[:message].to_s if ok.zero?

        out_ptr.read_string(size_ptr.read_ulong)
      ensure
        LibPNG.png_image_free(img) if img
      end
    end
  end
end

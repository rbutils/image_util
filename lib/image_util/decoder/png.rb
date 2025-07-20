require_relative "../libpng"

module ImageUtil
  module Decoder
    module PNG
      module_function

      def decode(data)
        img = LibPNG::PngImage.new
        img[:version] = LibPNG::PNG_IMAGE_VERSION

        data_ptr = FFI::MemoryPointer.from_string(data)
        ok = LibPNG.png_image_begin_read_from_memory(img, data_ptr, data.bytesize)
        raise StandardError, img[:message].to_s if ok.zero?

        img[:format] = LibPNG::PNG_FORMAT_RGBA
        row_stride = img[:width] * 4
        buffer_ptr = FFI::MemoryPointer.new(:uchar, row_stride * img[:height])

        ok = LibPNG.png_image_finish_read(img, nil, buffer_ptr, row_stride, nil)
        raise StandardError, img[:message].to_s if ok.zero?

        raw = buffer_ptr.read_string(row_stride * img[:height])
        io_buf = IO::Buffer.for(raw)
        buf = ImageUtil::Image::Buffer.new([img[:width], img[:height]], 8, 4, io_buf)
        ImageUtil::Image.from_buffer(buf)
      ensure
        LibPNG.png_image_free(img) if img
      end
    end
  end
end

module ImageUtil
  module Codec
    module ImageMagick
      module_function

      def encode(image)
        IO.popen("magick pam:- sixel:-", "r+") do |io|
          io << Codec::Pam.encode(image, fill_to: 6)
          io.close_write
          io.read
        end
      end

      def encode_io(image, io)
        io << encode(image)
      end

      def decode(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end

      def decode_io(*)
        raise UnsupportedFormatError, "decode not supported for sixel"
      end

      Codec.register(:sixel, self)
    end
  end
end

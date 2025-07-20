module ImageUtil
  module Codec
    class UnsupportedFormatError < Error; end

    @registry = {}

    class << self
      attr_reader :registry

      def register(format, mod)
        registry[format.to_s.downcase] = mod
      end

      def supported?(format)
        codec = registry[format.to_s.downcase]
        return false unless codec

        if codec.respond_to?(:supported?)
          codec.supported?(format)
        else
          true
        end
      end

      def fetch(format)
        registry[format.to_s.downcase] ||
          (raise UnsupportedFormatError, "unsupported format #{format}")
      end

      def encode(format, image, **kwargs)
        fetch(format).encode(format, image, **kwargs)
      end

      def decode(format, data, **kwargs)
        fetch(format).decode(format, data, **kwargs)
      end

      def encode_io(format, image, io, **kwargs)
        codec = fetch(format)
        if codec.respond_to?(:encode_io)
          codec.encode_io(format, image, io, **kwargs)
        else
          io << codec.encode(format, image, **kwargs)
        end
      end

      def decode_io(format, io, **kwargs)
        codec = fetch(format)
        if codec.respond_to?(:decode_io)
          codec.decode_io(format, io, **kwargs)
        else
          codec.decode(format, io.read, **kwargs)
        end
      end
    end

    autoload :Libpng, "image_util/codec/libpng"
    autoload :Libturbojpeg, "image_util/codec/libturbojpeg"
    autoload :Pam, "image_util/codec/pam"
    autoload :ImageMagick, "image_util/codec/image_magick"

    Libpng
    Libturbojpeg
    Pam
    ImageMagick
  end
end

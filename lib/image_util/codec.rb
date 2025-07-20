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
        registry.key?(format.to_s.downcase)
      end

      def fetch(format)
        registry[format.to_s.downcase] ||
          (raise UnsupportedFormatError, "unsupported format #{format}")
      end

      def encode(format, image, **kwargs)
        fetch(format).encode(image, **kwargs)
      end

      def decode(format, data, **kwargs)
        fetch(format).decode(data, **kwargs)
      end

      def encode_io(format, image, io, **kwargs)
        codec = fetch(format)
        if codec.respond_to?(:encode_io)
          codec.encode_io(image, io, **kwargs)
        else
          io << codec.encode(image, **kwargs)
        end
      end

      def decode_io(format, io, **kwargs)
        codec = fetch(format)
        if codec.respond_to?(:decode_io)
          codec.decode_io(io, **kwargs)
        else
          codec.decode(io.read, **kwargs)
        end
      end
    end

    require_relative "codec/libpng"
    require_relative "codec/pam"
    require_relative "codec/image_magick"
  end
end

# frozen_string_literal: true

module ImageUtil
  module Codec
    class UnsupportedFormatError < Error; end

    @encoders = []
    @decoders = []

    class << self
      attr_reader :encoders, :decoders

      def register_encoder(codec_const, *formats)
        encoders << { codec: codec_const, formats: formats.map { |f| f.to_s.downcase } }
      end

      def register_decoder(codec_const, *formats)
        decoders << { codec: codec_const, formats: formats.map { |f| f.to_s.downcase } }
      end

      def register_codec(codec_const, *formats)
        register_encoder(codec_const, *formats)
        register_decoder(codec_const, *formats)
      end

      def supported?(format)
        fmt = format.to_s.downcase
        encoders.any? { |r| r[:formats].include?(fmt) && codec_supported?(r[:codec], fmt) } ||
          decoders.any? { |r| r[:formats].include?(fmt) && codec_supported?(r[:codec], fmt) }
      end

      def encode(format, image, codec: nil, **kwargs)
        codec = find_codec(encoders, format, codec)
        codec.encode(format, image, **kwargs)
      end

      def decode(format, data, codec: nil, **kwargs)
        codec = find_codec(decoders, format, codec)
        codec.decode(format, data, **kwargs)
      end

      def encode_io(format, image, io, codec: nil, **kwargs)
        codec = find_codec(encoders, format, codec)
        if codec.respond_to?(:encode_io)
          codec.encode_io(format, image, io, **kwargs)
        else
          io << codec.encode(format, image, **kwargs)
        end
      end

      def decode_io(format, io, codec: nil, **kwargs)
        codec = find_codec(decoders, format, codec)
        if codec.respond_to?(:decode_io)
          codec.decode_io(format, io, **kwargs)
        else
          codec.decode(format, io.read, **kwargs)
        end
      end

      private

      def find_codec(list, format, preferred = nil)
        fmt = format.to_s.downcase
        if preferred
          r = list.find { |e| e[:formats].include?(fmt) && e[:codec].to_s == preferred.to_s }
          raise UnsupportedFormatError, "unsupported format #{format}" unless r

          codec = const_get(r[:codec])
          unless !codec.respond_to?(:supported?) || codec.supported?(fmt.to_sym)
            raise UnsupportedFormatError, "unsupported format #{format}"
          end

          return codec
        end

        list.each do |r|
          next unless r[:formats].include?(fmt)

          codec = const_get(r[:codec])
          next if codec.respond_to?(:supported?) && !codec.supported?(fmt.to_sym)

          return codec
        end
        raise UnsupportedFormatError, "unsupported format #{format}"
      end

      def codec_supported?(codec_const, fmt)
        codec = const_get(codec_const)
        !codec.respond_to?(:supported?) || codec.supported?(fmt.to_sym)
      end
    end

    autoload :Guard, "image_util/codec/_guard"

    autoload :Libpng, "image_util/codec/libpng"
    autoload :Libturbojpeg, "image_util/codec/libturbojpeg"
    autoload :Pam, "image_util/codec/pam"
    autoload :Libsixel, "image_util/codec/libsixel"
    autoload :ImageMagick, "image_util/codec/image_magick"
    autoload :RubySixel, "image_util/codec/ruby_sixel"

    register_codec :Pam, :pam
    register_codec :Libpng, :png
    register_codec :Libturbojpeg, :jpeg
    register_encoder :Libsixel, :sixel
    register_encoder :ImageMagick, :sixel
    register_encoder :RubySixel, :sixel
  end
end

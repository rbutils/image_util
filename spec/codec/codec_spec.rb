require 'spec_helper'

module ImageUtil
  module Codec
    module ParamTest
      SUPPORTED_FORMATS = [:param].freeze

      def self.supported?(_format = nil) = true

      def self.encode(_format, _image, **kwargs)
        @encode = kwargs
        'ok'
      end

      def self.decode(_format, _data, **kwargs)
        @decode = kwargs
        ImageUtil::Image.new(1,1)
      end

      def self.encode_io(_format, _image, io, **kwargs)
        @encode_io = kwargs
        io << 'x'
      end

      def self.decode_io(_format, _io, **kwargs)
        @decode_io = kwargs
        ImageUtil::Image.new(1,1)
      end
    end
  end
end

RSpec.describe ImageUtil::Codec do
  it 'raises UnsupportedFormatError for unknown format' do
    -> { ImageUtil::Codec.encode(:foo, ImageUtil::Image.new(1,1)) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'passes parameters to codec methods' do
    ImageUtil::Codec.register_codec :ParamTest, :param

    img = ImageUtil::Image.new(1,1)
    io = StringIO.new
    ImageUtil::Codec.encode(:param, img, foo: 1)
    ImageUtil::Codec.decode(:param, 'data', bar: 2)
    ImageUtil::Codec.encode_io(:param, img, io, baz: 3)
    ImageUtil::Codec.decode_io(:param, StringIO.new('x'), qux: 4)

    ImageUtil::Codec::ParamTest.instance_variable_get(:@encode).should == { foo: 1 }
    ImageUtil::Codec::ParamTest.instance_variable_get(:@decode).should == { bar: 2 }
    ImageUtil::Codec::ParamTest.instance_variable_get(:@encode_io).should == { baz: 3 }
    ImageUtil::Codec::ParamTest.instance_variable_get(:@decode_io).should == { qux: 4 }
  end
end

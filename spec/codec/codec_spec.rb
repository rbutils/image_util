require 'spec_helper'

RSpec.describe ImageUtil::Codec do
  it 'raises UnsupportedFormatError for unknown format' do
    -> { ImageUtil::Codec.encode(:foo, ImageUtil::Image.new(1,1)) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  describe 'preferred codec selection' do
    before do
      class TestCodec
        def self.encode(*) = 'enc'
        def self.supported?(*) = true
      end
      ImageUtil::Codec.register_codec TestCodec.name.to_sym, :tst
    end

    after do
      ImageUtil::Codec.encoders.pop
      ImageUtil::Codec.decoders.pop
      Object.send(:remove_const, :TestCodec)
    end

    it 'uses preferred codec when supported' do
      img = ImageUtil::Image.new(1,1)
      ImageUtil::Codec.encode(:tst, img, codec: 'TestCodec').should == 'enc'
    end

    it 'raises when preferred codec unsupported' do
      def TestCodec.supported?(*) = false
      img = ImageUtil::Image.new(1,1)
      -> { ImageUtil::Codec.encode(:tst, img, codec: 'TestCodec') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    end

    it 'raises when preferred codec is missing' do
      img = ImageUtil::Image.new(1,1)
      -> { ImageUtil::Codec.encode(:tst, img, codec: 'Missing') }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
    end
  end
end

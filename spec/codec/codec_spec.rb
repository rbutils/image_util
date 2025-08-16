require 'spec_helper'

RSpec.describe ImageUtil::Codec do
  it 'raises UnsupportedFormatError for unknown format' do
    -> { ImageUtil::Codec.encode(:foo, ImageUtil::Image.new(1,1)) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'raises UnsupportedFormatError for unknown decode format' do
    -> { ImageUtil::Codec.decode(:foo, "data") }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end

  it 'supports detecting PAM format' do
    ImageUtil::Codec.supported?(:pam).should be true
  end

  it 'returns false for unsupported format' do
    ImageUtil::Codec.supported?(:nonexistent).should be false
  end

  it 'detects format from PAM data' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] }
    pam_data = img.to_string(:pam)
    ImageUtil::Codec.detect(pam_data).should == :pam
  end

  it 'returns nil when format cannot be detected' do
    ImageUtil::Codec.detect("garbage").should be_nil
  end

  it 'encodes and decodes via IO' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[100, 200, 50] }
    io = StringIO.new
    ImageUtil::Codec.encode_io(:pam, img, io)
    io.rewind
    decoded = ImageUtil::Codec.decode_io(:pam, io)
    decoded[0, 0].should == ImageUtil::Color[100, 200, 50, 255]
  end

  it 'detects format from IO' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] }
    io = StringIO.new
    ImageUtil::Codec.encode_io(:pam, img, io)
    io.rewind
    ImageUtil::Codec.detect_io(io).should == :pam
  end

  it 'respects preferred codec when specified' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] }
    result = ImageUtil::Codec.encode(:pam, img, codec: :Pam)
    result.should include("P7")
  end

  it 'raises when preferred codec does not support format' do
    img = ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] }
    -> { ImageUtil::Codec.encode(:pam, img, codec: :RubySixel) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end
end

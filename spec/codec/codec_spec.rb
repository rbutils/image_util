require 'spec_helper'

RSpec.describe ImageUtil::Codec do
  it 'supports png format' do
    ImageUtil::Codec.supported?(:png).should be true
  end

  it 'raises UnsupportedFormatError for unknown format' do
    -> { ImageUtil::Codec.encode(:foo, ImageUtil::Image.new(1,1)) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end
end

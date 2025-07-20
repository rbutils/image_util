require 'spec_helper'

RSpec.describe ImageUtil::Codec do
  it 'raises UnsupportedFormatError for unknown format' do
    -> { ImageUtil::Codec.encode(:foo, ImageUtil::Image.new(1,1)) }.should raise_error(ImageUtil::Codec::UnsupportedFormatError)
  end
end

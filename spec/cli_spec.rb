require 'spec_helper'
require 'image_util/cli'
require 'stringio'

def capture_stdout
  old = $stdout
  out = StringIO.new
  $stdout = out
  yield
  out.string
ensure
  $stdout = old
end

RSpec.describe ImageUtil::CLI do
  it 'prints codec and format information' do
    allow(ImageUtil::Codec::Pam).to receive(:supported?).and_return(true)
    allow(ImageUtil::Codec::Kitty).to receive(:supported?).and_return(false)
    allow(ImageUtil::Codec::Libpng).to receive(:supported?).and_return(false)
    allow(ImageUtil::Codec::Libturbojpeg).to receive(:supported?).and_return(true)
    allow(ImageUtil::Codec::Libsixel).to receive(:supported?).and_return(true)
    allow(ImageUtil::Codec::ImageMagick).to receive(:supported?).and_return(true)
    allow(ImageUtil::Codec::ChunkyPng).to receive(:supported?).and_return(true)
    allow(ImageUtil::Codec::RubySixel).to receive(:supported?).and_return(false)

    allow(ImageUtil::Terminal).to receive(:detect_support).and_return([:sixel])

    output = capture_stdout { described_class.start(%w[support]) }
    output.should match(/Pam\s+supported/)
    output.should match(/Kitty\s+not supported/)
    output.should match(/png\s+ImageMagick/)
    output.should match(/jpeg\s+Libturbojpeg/)
    output.should match(/Terminal features:/)
    output.should match(/sixel/)
  end
end

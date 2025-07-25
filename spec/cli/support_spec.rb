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

    output = capture_stdout { described_class.start(%w[support]) }
    output.should include('Pam - supported')
    output.should include('Kitty - not supported')
    output.should include('png - ImageMagick')
    output.should include('jpeg - Libturbojpeg')
  end
end

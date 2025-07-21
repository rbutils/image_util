require 'spec_helper'

RSpec.describe ImageUtil::Magic do
  it 'returns nil for nil data' do
    described_class.detect(nil).should be_nil
  end

  it 'detects formats from magic numbers' do
    described_class.detect("\x89PNG\r\n\x1a\nrest".b).should == :png
    described_class.detect("P7\nrest".b).should == :pam
  end

  it 'detects format from seekable io' do
    io = StringIO.new("P7\nabc")
    fmt, returned = described_class.detect_io(io)
    fmt.should == :pam
    returned.should equal(io)
    io.pos.should == 0
  end

  it 'detects format from unseekable io' do
    r, w = IO.pipe
    w.write("P7\nabc")
    w.close
    fmt, new_io = described_class.detect_io(r)
    fmt.should == :pam
    new_io.read.should == "P7\nabc"
  end

  it 'returns nil for unknown magic numbers' do
    described_class.detect('xyz'.b).should be_nil
  end
end

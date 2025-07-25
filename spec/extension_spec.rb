require 'spec_helper'

RSpec.describe ImageUtil::Extension do
  it 'returns nil for nil path' do
    described_class.detect(nil).should be_nil
  end

  it 'detects formats from extensions' do
    described_class.detect('file.png').should == :png
    described_class.detect('file.jpeg').should == :jpeg
    described_class.detect('file.JPG').should == :jpeg
    described_class.detect('file.pam').should == :pam
    described_class.detect('file.gif').should == :gif
    described_class.detect('file.apng').should == :apng
  end

  it 'returns nil for unknown extensions' do
    described_class.detect('file.xyz').should be_nil
  end
end

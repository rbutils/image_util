require 'spec_helper'
require 'benchmark'

RSpec.describe ImageUtil::Benchmarking do
  it 'runs image creation benchmark' do
    result = described_class.image_creation(1)
    result.should be_a(Benchmark::Tms)
  end
end

require 'spec_helper'
require 'benchmark/ips'

RSpec.describe ImageUtil::Benchmarking do
  it 'runs image creation benchmark' do
    result = described_class.image_creation(0.1)
    result.should be_a(Benchmark::IPS::Report)
  end
end

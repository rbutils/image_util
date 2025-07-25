# frozen_string_literal: true

require "benchmark/ips"

module ImageUtil
  module Benchmarking
    module_function

    # Benchmarks creating a 64×64×64 black image for the given time in seconds.
    def image_creation(seconds = 5)
      ::Benchmark.ips do |x|
        x.warmup = 0
        x.time = seconds
        x.report("from Symbol") { Image.new(64, 64, 64) { :black } }
        x.report("from Array (4->4 channels)") { Image.new(64, 64, 64) { |x,y,z| [x,y,z,255] } }
        x.report("from Array (3->4 channels)") { Image.new(64, 64, 64) { |x,y,z| [x,y,z] } }
        x.report("from Array (3->3 channels)") { Image.new(64, 64, 64, channels: 3) { |x,y,z| [x,y,z] } }
      end
    end

    def run(seconds = 5)
      image_creation(seconds)
    end
  end
end

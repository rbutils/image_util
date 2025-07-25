# frozen_string_literal: true

require "benchmark/ips"

module ImageUtil
  module Benchmarking
    module_function

    # Benchmarks creating a 64×64×64 black image for the given time in seconds.
    def image_creation(seconds = 1)
      ::Benchmark.ips do |x|
        x.warmup = 0
        x.time = seconds
        x.report("image_creation") { Image.new(64, 64, 64) { :black } }
      end
    end

    def run(seconds = 1)
      image_creation(seconds)
    end
  end
end

# frozen_string_literal: true

require "benchmark"

module ImageUtil
  module Benchmarking
    module_function

    # Creates a 64x64x64 image filled with black pixels multiple times
    # to provide a heavy yet quick benchmark.
    def image_creation(iterations = 5)
      ::Benchmark.measure do
        iterations.times do
          Image.new(64, 64, 64) { :black }
        end
      end
    end
  end
end

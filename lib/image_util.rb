# frozen_string_literal: true

require_relative "image_util/version"

module ImageUtil
  class Error < StandardError; end
  # Your code goes here...

  autoload :Color, "image_util/color"
  autoload :Image, "image_util/image"
  autoload :Util, "image_util/util"
  autoload :Codec, "image_util/codec"
  autoload :Magic, "image_util/magic"
  autoload :Filter, "image_util/filter"
  autoload :Statistic, "image_util/statistic"
  autoload :Terminal, "image_util/terminal"
  autoload :View, "image_util/view"
  autoload :CLI, "image_util/cli"
  autoload :Benchmarking, "image_util/benchmarking"
end

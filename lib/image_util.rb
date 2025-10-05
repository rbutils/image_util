# frozen_string_literal: true

require_relative "image_util/version"

module ImageUtil
  class Error < StandardError; end
  # Your code goes here...

  autoload :BitmapFont, "image_util/bitmap_font"
  autoload :Color, "image_util/color"
  autoload :Image, "image_util/image"
  autoload :Util, "image_util/util"
  autoload :Codec, "image_util/codec"
  autoload :Inspectable, "image_util/inspectable"
  autoload :Magic, "image_util/magic"
  autoload :Extension, "image_util/extension"
  autoload :Filter, "image_util/filter"
  autoload :Generator, "image_util/generator"
  autoload :Statistic, "image_util/statistic"
  autoload :Terminal, "image_util/terminal"
  autoload :View, "image_util/view"
  autoload :CLI, "image_util/cli"
  autoload :Benchmarking, "image_util/benchmarking"
end

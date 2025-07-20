# frozen_string_literal: true

require_relative "image_util/version"

module ImageUtil
  class Error < StandardError; end
  # Your code goes here...

  autoload :Color, "image_util/color"
  autoload :Image, "image_util/image"
  autoload :Util, "image_util/util"

  module Codec
    autoload :Libpng, "image_util/codec/libpng"
  end
end

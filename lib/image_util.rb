# frozen_string_literal: true

require_relative "image_util/version"

module ImageUtil
  class Error < StandardError; end
  # Your code goes here...

  autoload :Color, "image_util/color"
  autoload :Image, "image_util/image"
  autoload :Util, "image_util/util"
  autoload :LibPNG, "image_util/libpng"

  module Encoder
    autoload :PNG, "image_util/encoder/png"
  end

  module Decoder
    autoload :PNG, "image_util/decoder/png"
  end
end

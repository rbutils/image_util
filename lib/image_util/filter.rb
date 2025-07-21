# frozen_string_literal: true

module ImageUtil
  module Filter
    autoload :Dither, "image_util/filter/dither"
    autoload :Background, "image_util/filter/background"
    autoload :Paste, "image_util/filter/paste"
    autoload :Draw, "image_util/filter/draw"

    autoload :Mixin, "image_util/filter/_mixin"
  end
end

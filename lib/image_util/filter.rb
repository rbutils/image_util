# frozen_string_literal: true

module ImageUtil
  module Filter
    autoload :Palette, "image_util/filter/palette"
    autoload :Background, "image_util/filter/background"
    autoload :Paste, "image_util/filter/paste"
    autoload :Draw, "image_util/filter/draw"
    autoload :Resize, "image_util/filter/resize"
    autoload :Transform, "image_util/filter/transform"
    autoload :Redimension, "image_util/filter/redimension"
    autoload :Colors, "image_util/filter/colors"

    autoload :Mixin, "image_util/filter/_mixin"
  end
end

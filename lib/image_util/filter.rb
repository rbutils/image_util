# frozen_string_literal: true

module ImageUtil
  module Filter
    autoload :Dither, "image_util/filter/dither"
    autoload :Background, "image_util/filter/background"
    autoload :Mixin, "image_util/filter/mixin"
  end
end

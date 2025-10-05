# frozen_string_literal: true

module ImageUtil
  module Inspectable
    def pretty_print(pp)
      image = inspect_image
      return super unless image.is_a?(ImageUtil::Image)

      rendered = ImageUtil::Terminal.output_image($stdin, $stdout, image)
      if rendered
        pp.flush
        pp.output << rendered
        pp.text("", 0)
      else
        super
      end
    rescue LoadError
      super
    end

    def inspect_image
      raise NotImplementedError, "including classes must implement #inspect_image"
    end
  end
end

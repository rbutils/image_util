# frozen_string_literal: true

module ImageUtil
  module Generator
    module Example
      def example_rose = Image.from_file("#{__dir__}/example/rose.png", :png)
    end
  end
end    

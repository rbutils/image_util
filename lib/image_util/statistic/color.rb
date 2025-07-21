module ImageUtil
  module Statistic
    module Color
      def histogram = each_pixel.to_a.tally
      def unique_colors = histogram.keys
      def unique_color_count = unique_colors.length
    end
  end
end

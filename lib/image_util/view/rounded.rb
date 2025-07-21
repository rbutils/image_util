# frozen_string_literal: true

module ImageUtil
  module View
    # Access pixels by rounding coordinates to the nearest integer.
    Rounded = Data.define(:image) do
      def [](*location)
        image[*location.map { |i| i.round }]
      end

      def []=(*location, value)
        image[*location.map { |i| i.round }] = value
      end
    end
  end
end

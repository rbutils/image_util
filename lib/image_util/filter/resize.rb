# frozen_string_literal: true

module ImageUtil
  module Filter
    module Resize
      extend ImageUtil::Filter::Mixin
      def resize(*new_dimensions, view: View::Interpolated)
        src = self.view(view)

        factors = new_dimensions.zip(dimensions).map do |new_dim, old_dim|
          new_dim == 1 ? 0.0 : (old_dim - 1).to_f / (new_dim - 1)
        end

        Image.new(*new_dimensions, color_bits: color_bits, channels: channels) do |loc|
          src_loc = loc.zip(factors).map { |coord, factor| coord * factor }
          src[*src_loc]
        end
      end

      define_mutable_version :resize
    end
  end
end

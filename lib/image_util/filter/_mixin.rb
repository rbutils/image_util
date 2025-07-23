# frozen_string_literal: true

module ImageUtil
  module Filter
    module Mixin
      def define_immutable_version(*names)
        names.each do |name|
          define_method(name) do |*args, **kwargs, &block|
            dup.tap { |obj| obj.public_send("#{name}!", *args, **kwargs, &block) }
          end
        end
      end

      def axis_to_number(axis)
        axis = 0 if axis == :x
        axis = 1 if axis == :y
        axis = 2 if axis == :z
        axis
      end

      module_function :axis_to_number
    end
  end
end

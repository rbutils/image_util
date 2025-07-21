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
    end
  end
end

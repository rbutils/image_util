# frozen_string_literal: true

module ImageUtil
  module Immutable
    def define_immutable_version(name, as: name)
      define_method(as) do |*args, **kwargs, &block|
        dup.tap { |obj| obj.public_send("#{name}!", *args, **kwargs, &block) }
      end
    end
  end
end

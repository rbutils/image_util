# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  minimum_coverage 80
end

require "image_util"

# Don't count coverage for codecs not supported by the current environment
ImageUtil::Codec.constants.each do |name|
  const = ImageUtil::Codec.const_get(name)
  next unless const.is_a?(Module)
  next unless const.respond_to?(:supported?)
  next if const.supported?

  file = "lib/image_util/codec/#{name.to_s.gsub(/([a-z\d])([A-Z])/, '\\1_\\2').downcase}.rb"
  SimpleCov.add_filter(file)
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :should
  end

  config.mock_with :rspec do |c|
    c.syntax = %i[should expect]
  end
end

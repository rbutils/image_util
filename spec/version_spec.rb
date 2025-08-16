# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::VERSION do
  it "is defined" do
    ImageUtil::VERSION.should be_a(String)
  end

  it "follows semantic versioning format" do
    ImageUtil::VERSION.should match(/\A\d+\.\d+\.\d+\z/)
  end

  it "is accessible from main module" do
    defined?(ImageUtil::VERSION).should be_truthy
  end
end

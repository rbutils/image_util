# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::View do
  it "autoloads view modules" do
    -> { ImageUtil::View::Interpolated }.should_not raise_error
    -> { ImageUtil::View::Rounded }.should_not raise_error
  end
end

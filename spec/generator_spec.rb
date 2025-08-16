# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::Generator do
  it "autoloads generator modules" do
    -> { ImageUtil::Generator::BitmapText }.should_not raise_error
    -> { ImageUtil::Generator::Example }.should_not raise_error
  end
end

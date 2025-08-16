# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::Filter do
  it "autoloads filter modules" do
    -> { ImageUtil::Filter::Palette }.should_not raise_error
    -> { ImageUtil::Filter::Background }.should_not raise_error
    -> { ImageUtil::Filter::Paste }.should_not raise_error
    -> { ImageUtil::Filter::Draw }.should_not raise_error
    -> { ImageUtil::Filter::Resize }.should_not raise_error
    -> { ImageUtil::Filter::Transform }.should_not raise_error
    -> { ImageUtil::Filter::Redimension }.should_not raise_error
    -> { ImageUtil::Filter::Colors }.should_not raise_error
    -> { ImageUtil::Filter::BitmapText }.should_not raise_error
  end

  it "autoloads mixin module" do
    -> { ImageUtil::Filter::Mixin }.should_not raise_error
  end
end

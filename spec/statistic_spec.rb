# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::Statistic do
  it "autoloads statistic modules" do
    -> { ImageUtil::Statistic::Colors }.should_not raise_error
  end
end

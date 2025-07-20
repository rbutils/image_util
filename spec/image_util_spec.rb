# frozen_string_literal: true

RSpec.describe ImageUtil do
  it "has a version number" do
    ImageUtil::VERSION.should_not be nil
  end
end

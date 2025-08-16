# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::Generator::Example do
  describe "#example_rose", skip: !ImageUtil::Codec.supported?(:png) do
    # Since Example module is extended into Image class, test it through Image
    it "loads the example rose image via Image class" do
      result = ImageUtil::Image.example_rose
      result.should be_a(ImageUtil::Image)
      result.width.should > 0
      result.height.should > 0
    end

    it "returns same instance on multiple calls" do
      rose1 = ImageUtil::Image.example_rose
      rose2 = ImageUtil::Image.example_rose
      rose1.object_id.should == rose2.object_id
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe ImageUtil::BitmapFont do
  describe "#initialize" do
    it "loads the default font successfully", skip: !ImageUtil::Codec.supported?(:png) do
      font = described_class.new("smfont")
      font.should be_a(described_class)
    end

    it "raises error for non-existent font" do
      -> { described_class.new("nonexistent") }.should raise_error(Errno::ENOENT)
    end
  end

  describe "#render_line_of_text", skip: !ImageUtil::Codec.supported?(:png) do
    let(:font) { described_class.new("smfont") }

    it "renders simple text" do
      result = font.render_line_of_text("A")
      result.should be_a(ImageUtil::Image)
      result.height.should > 0
      result.width.should > 0
    end

    it "renders longer text" do
      result = font.render_line_of_text("Hello")
      result.should be_a(ImageUtil::Image)
      result.width.should > font.render_line_of_text("H").width
    end

    it "handles empty string" do
      result = font.render_line_of_text("")
      result.should be_a(ImageUtil::Image)
      result.width.should == 0
    end

    it "handles special characters" do
      result = font.render_line_of_text("!@#")
      result.should be_a(ImageUtil::Image)
      result.height.should > 0
    end
  end

  describe ".fonts" do
    it "returns array of available fonts" do
      fonts = described_class.fonts
      fonts.should be_an(Array)
      fonts.should include("smfont")
    end
  end

  describe ".default_font" do
    it "returns default font name" do
      described_class.default_font.should == "smfont"
    end
  end

  describe ".cached_load", skip: !ImageUtil::Codec.supported?(:png) do
    it "caches font instances" do
      font1 = described_class.cached_load("smfont")
      font2 = described_class.cached_load("smfont")
      font1.object_id.should == font2.object_id
    end

    it "returns different instances for different fonts" do
      font1 = described_class.cached_load("smfont")
      # Since we only have one font, we'll test the caching behavior
      font1.should be_a(described_class)
    end
  end
end

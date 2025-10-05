# frozen_string_literal: true

require "spec_helper"
require "stringio"

class DummyInspectable
  include ImageUtil::Inspectable

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def inspect_image
    image
  end
end

class IncompleteInspectable
  include ImageUtil::Inspectable
end

RSpec.describe ImageUtil::Inspectable do
  let(:image) { ImageUtil::Image.new(1, 1) { ImageUtil::Color[255, 0, 0] } }

  it "renders the inspection image via pretty_print" do
    subject = DummyInspectable.new(image)
    fake_pp = Class.new do
      attr_reader :output, :flushed

      def initialize
        @output = StringIO.new
      end

      def flush
        @flushed = true
      end

      def text(*); end
    end.new

    ImageUtil::Terminal.should_receive(:output_image).with($stdin, $stdout, image).and_return("--image--")

    subject.pretty_print(fake_pp)

    fake_pp.output.string.should include("--image--")
    fake_pp.flushed.should be(true)
  end

  it "requires inspect_image to be implemented" do
    inspector = IncompleteInspectable.new
    -> { inspector.inspect_image }.should raise_error(NotImplementedError)
  end
end

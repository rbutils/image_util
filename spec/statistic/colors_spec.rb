require 'spec_helper'

RSpec.describe ImageUtil::Statistic::Colors do
  let(:image) do
    ImageUtil::Image.new(2, 1) { |x, _y| ImageUtil::Color[x, 0, 0] }
  end

  it 'builds a histogram of pixel colors' do
    image.histogram.should == {
      ImageUtil::Color[0, 0, 0, 255] => 1,
      ImageUtil::Color[1, 0, 0, 255] => 1
    }
  end

  it 'returns unique colors' do
    image.unique_colors.should match_array([
                                             ImageUtil::Color[0, 0, 0, 255],
                                             ImageUtil::Color[1, 0, 0, 255]
                                           ])
  end

  it 'counts unique colors' do
    image.unique_color_count.should == 2
  end
end

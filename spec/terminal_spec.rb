require 'spec_helper'

RSpec.describe ImageUtil::Terminal do
  let(:termin) { Object.new.tap { |o| def o.tty? = true } }
  let(:termout) { Object.new.tap { |o| def o.tty? = true } }

  describe '.detect_support' do
    it 'returns empty array when not ttys' do
      def termin.tty? = false
      described_class.detect_support(termin, termout).should == []
    end

    it 'detects kitty support' do
      allow(described_class).to receive(:query_terminal).and_return(true, false)
      described_class.detect_support(termin, termout).should == %i[tty kitty]
    end

    it 'detects sixel support' do
      allow(described_class).to receive(:query_terminal).and_return(false, true)
      described_class.detect_support(termin, termout).should == %i[tty sixel]
    end

    it 'detects iterm2 support' do
      allow(described_class).to receive(:query_terminal).and_return(false, false)
      termout.remove_instance_variable(:@imageutil_support_cache) if termout.instance_variable_defined?(:@imageutil_support_cache)
      begin
        orig = ENV['TERM_PROGRAM']
        ENV['TERM_PROGRAM'] = 'iTerm.app'
        described_class.detect_support(termin, termout).should include(:iterm2)
      ensure
        ENV['TERM_PROGRAM'] = orig
        termout.remove_instance_variable(:@imageutil_support_cache) if termout.instance_variable_defined?(:@imageutil_support_cache)
      end
    end

    it 'caches support results' do
      allow(described_class).to receive(:query_terminal).and_return(false)
      described_class.detect_support(termin, termout).should == %i[tty]
      described_class.should_not_receive(:query_terminal)
      described_class.detect_support(termin, termout).should == %i[tty]
    end
  end

  describe '.output_image' do
    it 'uses kitty when available' do
      img = ImageUtil::Image.new(1, 1)
      allow(described_class).to receive(:detect_support).and_return(%i[tty kitty])
      img.should_receive(:to_string).with(:kitty).and_return('K')
      described_class.output_image(termin, termout, img).should == 'K'
    end

    it 'uses iterm2 when kitty is not available' do
      img = ImageUtil::Image.new(1, 1)
      allow(described_class).to receive(:detect_support).and_return(%i[tty iterm2])
      img.should_receive(:to_string).with(:iterm2).and_return('I')
      described_class.output_image(termin, termout, img).should == 'I'
    end

    it 'uses sixel when kitty is not available' do
      img = ImageUtil::Image.new(1, 1)
      allow(described_class).to receive(:detect_support).and_return(%i[tty sixel])
      img.should_receive(:to_string).with(:sixel).and_return('S')
      described_class.output_image(termin, termout, img).should == 'S'
    end
  end

  describe '.query_terminal' do
    it 'returns false when reading fails' do
      failing_termin = Object.new
      def failing_termin.raw
        raise EOFError
      end
      termout = Object.new.tap do |o|
        def o.write(*) end
        def o.flush; end
      end
      described_class.query_terminal(failing_termin, termout, 'Q') { true }.should be false
    end
  end
end

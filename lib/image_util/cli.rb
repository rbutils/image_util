# frozen_string_literal: true

require "thor"

module ImageUtil
  class CLI < Thor
    desc "support", "Display codec support, default codecs and terminal features"
    def support
      width = (codec_names + format_names).map(&:length).max
      use_color = Terminal.detect_support.include?(:tty)

      puts "Codecs:"
      codec_names.each do |name|
        mod = Codec.const_get(name)
        supported = mod.supported?
        status = supported ? color("supported", 32, use_color) : color("not supported", 31, use_color)
        puts format("  %-#{width}s  %s", name, status)
      end

      puts "\nFormats:"
      format_names.each do |fmt|
        codec = default_codec(fmt)
        codec_name = codec ? color(codec.to_s, 32, use_color) : color("none", 31, use_color)
        puts format("  %-#{width}s  %s", fmt, codec_name)
      end

      puts "\nTerminal features:"
      Terminal.detect_support.each do |feat|
        puts "  #{color(feat, 34, use_color)}"
      end
    end

    no_commands do
      def codec_names = Codec.constants.select { |name| Codec.const_get(name).respond_to?(:supported?) }
      def format_names = (Codec.encoders + Codec.decoders).flat_map { |r| r[:formats] }.uniq.sort

      def default_codec(fmt)
        Codec.encoders.each do |r|
          next unless r[:formats].include?(fmt.to_s)

          codec_mod = Codec.const_get(r[:codec])
          next if codec_mod.respond_to?(:supported?) && !codec_mod.supported?(fmt.to_sym)

          return r[:codec]
        end
        nil
      end

      def color(text, code, enable)
        enable ? "\e[#{code}m#{text}\e[0m" : text
      end
    end
  end
end

# frozen_string_literal: true

require "thor"

module ImageUtil
  class CLI < Thor
    desc "support", "Display codec support and default codecs"
    def support
      puts "Codecs:"
      codec_names.each do |name|
        mod = Codec.const_get(name)
        supported = !mod.respond_to?(:supported?) || mod.supported?
        status = supported ? "supported" : "not supported"
        puts "  #{name} - #{status}"
      end
      puts "\nFormats:"
      format_names.each do |fmt|
        codec = default_codec(fmt)
        codec_name = codec ? codec.to_s : "none"
        puts "  #{fmt} - #{codec_name}"
      end
    end

    no_commands do
      def codec_names = Codec.constants.grep_v(/^_/).sort

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
    end
  end
end

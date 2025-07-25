# frozen_string_literal: true

module ImageUtil
  module Codec
    module ImageMagick
      SUPPORTED_FORMATS = %i[sixel jpeg png gif apng].freeze

      extend Guard

      module_function

      def magick_available?
        return @magick_available unless @magick_available.nil?

        @magick_available = system("magick", "-version", out: File::NULL, err: File::NULL)
      end

      def magick_formats
        return @magick_formats if defined?(@magick_formats)

        out = IO.popen(%w[magick -list format], &:read)
        @magick_formats = out.lines.filter_map do |line|
          next unless line.start_with?(" ")

          fmt = line[0,9].gsub(" ", "").downcase
          fmt.empty? ? nil : fmt
        end
        @magick_formats
      rescue StandardError
        @magick_formats = []
      end

      def supported?(format = nil)
        return false unless magick_available?

        return true if format.nil?

        fmt = format.to_s.downcase
        SUPPORTED_FORMATS.include?(fmt.to_sym) && magick_formats.include?(fmt)
      end

      def encode(format, image)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        fmt = format.to_s.downcase

        if image.dimensions.length <= 2 || fmt == "sixel"
          img = image
          if img.dimensions.length == 1
            img = img.redimension(img.width, 1)
          end
          if fmt == "sixel"
            pad = (6 - (img.height % 6)) % 6
            img = img.redimension(img.width, img.height + pad) if pad > 0
          end
          pam = Codec::Pam.encode(:pam, img)

          IO.popen(["magick", "pam:-", "#{fmt}:-"], "r+b") do |proc_io|
            proc_io << pam
            proc_io.close_write
            proc_io.read
          end
        else
          frames = image.buffer.last_dimension_split.map { |b| Image.from_buffer(b) }
          stream = frames.map { |f| Codec::Pam.encode(:pam, f) }.join
          IO.popen(["magick", "pam:-", "#{fmt}:-"], "r+b") do |proc_io|
            proc_io << stream
            proc_io.close_write
            proc_io.read
          end
        end
      end

      def decode(format, data)
        guard_supported_format!(format, SUPPORTED_FORMATS)

        cmd = ["magick", "#{format}:-"]
        cmd << "-coalesce" if %i[gif apng].include?(format.to_s.downcase.to_sym)
        cmd += ["-depth", "8", "pam:-"]
        IO.popen(cmd, "r+b") do |proc_io|
          proc_io << data
          proc_io.close_write

          frames = []
          while (frame = Codec::Pam.decode_frame(proc_io))
            frames << frame
          end

          if frames.length == 1
            frames.first
          else
            first = frames.first
            img = Image.new(first.width, first.height, frames.length,
                            color_bits: first.color_bits, channels: first.channels)
            frames.each_with_index do |frame, idx|
              offset = img.buffer.offset_of(0, 0, idx)
              bytes = frame.width * frame.height * frame.pixel_bytes
              img.buffer.io_buffer.copy(frame.buffer.io_buffer, offset, bytes)
            end
            img
          end
        end
      end
    end
  end
end

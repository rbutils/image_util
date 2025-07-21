# frozen_string_literal: true

module ImageUtil
  module Codec
    module Magic
      MAGIC_NUMBERS = {
        pam: "P7\n".b,
        png: "\x89PNG\r\n\x1a\n".b,
        jpeg: "\xFF\xD8".b
      }.freeze

      BYTES_NEEDED = MAGIC_NUMBERS.values.map(&:bytesize).max

      module_function

      def detect(data)
        return nil unless data

        MAGIC_NUMBERS.each do |fmt, magic|
          return fmt if data.start_with?(magic)
        end
        nil
      end

      def detect_io(io)
        pos = io.pos if io.respond_to?(:pos)
        data = io.read(BYTES_NEEDED)
        io.seek(pos) if pos && io.respond_to?(:seek)
        io.rewind if !pos && io.respond_to?(:rewind)
        detect(data)
      end
    end
  end
end

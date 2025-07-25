# frozen_string_literal: true

require "stringio"

module ImageUtil
  module Magic
    MAGIC_NUMBERS = {
      pam: "P7\n".b,
      png: "\x89PNG\r\n\x1a\n".b,
      jpeg: "\xFF\xD8".b,
      gif: "GIF8".b
    }.freeze

    BYTES_NEEDED = MAGIC_NUMBERS.values.map(&:bytesize).max

    module_function

    def bytes_needed = BYTES_NEEDED

    def detect(data)
      return nil unless data

      if data.start_with?(MAGIC_NUMBERS[:png]) && data.byteslice(0, 256).include?("acTL")
        return :apng
      end

      MAGIC_NUMBERS.each do |fmt, magic|
        return fmt if data.start_with?(magic)
      end

      nil
    end

    def detect_io(io)      
      pos = io.pos
      data = io.read(BYTES_NEEDED)
      io.seek(pos)
      [detect(data), io]
    rescue Errno::ESPIPE, IOError
      data = io.read(BYTES_NEEDED)
      fmt = detect(data)
      rest = io.read
      new_io = StringIO.new((data || "") + (rest || ""))
      [fmt, new_io]
    end
  end
end

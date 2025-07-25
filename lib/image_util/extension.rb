# frozen_string_literal: true

module ImageUtil
  module Extension
    EXTENSIONS = {
      pam: [".pam"],
      png: [".png"],
      jpeg: [".jpg", ".jpeg"],
      gif: [".gif"],
      apng: [".apng"]
    }.freeze

    LOOKUP = EXTENSIONS.flat_map { |fmt, exts| exts.map { |e| [e, fmt] } }.to_h.freeze

    module_function

    def detect(path)
      return nil unless path

      ext = File.extname(path.to_s).downcase
      LOOKUP[ext]
    end
  end
end

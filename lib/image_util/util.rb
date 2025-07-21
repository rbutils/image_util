# frozen_string_literal: true

module ImageUtil
  module Util
    module_function

    # Applies configuration tweaks for IRB, if available.
    def irb_fixup
      IRB.conf[:USE_PAGER] = false
      IRB.CurrentContext.echo_on_assignment = true
    rescue StandardError
      nil
    end
  end
end

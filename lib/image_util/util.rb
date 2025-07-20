module ImageUtil
  module Util
    # FIXME: Doesn't really work. Temporary partial solution.
    module_function def unlock_irb(p)
      begin
        old_pager, IRB.conf[:USE_PAGER] = IRB.conf[:USE_PAGER], false
        old_echo, IRB.CurrentContext.echo_on_assignment = IRB.CurrentContext.echo_on_assignment, true
      rescue
        # If IRB is not present, we don't apply this hack.
        yield
        return
      end
      yield
      ObjectSpace.define_finalizer(p, ->(id) do
        IRB.conf[:USE_PAGER] = old_pager
        IRB.CurrentContext.echo_on_assignment = old_echo
      rescue
      end)
    end
  end
end

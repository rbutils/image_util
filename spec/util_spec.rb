require 'spec_helper'

RSpec.describe ImageUtil::Util do
  it 'returns nil when IRB is missing' do
    ImageUtil::Util.irb_fixup.should be_nil
  end

  it 'adjusts IRB settings when present' do
    fake_conf = { USE_PAGER: true }
    fake_ctx = Struct.new(:echo_on_assignment).new(false)
    fake_irb = Module.new do
      define_singleton_method(:conf) { fake_conf }
      # rubocop:disable Naming/MethodName
      define_singleton_method(:CurrentContext) { fake_ctx }
      # rubocop:enable Naming/MethodName
    end
    stub_const('IRB', fake_irb)

    ImageUtil::Util.irb_fixup
    fake_conf[:USE_PAGER].should be false
    fake_ctx.echo_on_assignment.should be true
  end
end

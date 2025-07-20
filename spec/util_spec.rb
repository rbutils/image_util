require 'spec_helper'

RSpec.describe ImageUtil::Util do
  it 'returns nil when IRB is missing' do
    ImageUtil::Util.unlock_irb(Object.new) { 5 }.should be_nil
  end
end

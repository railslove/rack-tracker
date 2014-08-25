RSpec.describe Rack::Tracker::HandlerSet do

  let(:set) do
    Rack::Tracker::HandlerSet.new do
      handler 'dummy', {foo: "bar"}
    end
  end

  describe '#to_a' do
    subject { set.to_a }
    specify { expect(subject.size).to eq(1) }
    specify { expect(subject).to match_array(Rack::Tracker::HandlerSet::Handler) }
  end

  describe '#first' do
    subject { set.first }
    specify { expect(subject.name).to eq('dummy') }
    specify { expect(subject.options).to eq({foo: "bar"}) }
  end

end

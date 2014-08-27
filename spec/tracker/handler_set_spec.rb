class Dummy < Rack::Tracker::Handler
end

RSpec.describe Rack::Tracker::HandlerSet do

  let(:set) do
    Rack::Tracker::HandlerSet.new do
      handler 'dummy', {foo: "bar"}
    end
  end

  describe '#each' do
    subject { set.each }
    specify { expect(subject.size).to eq(1) }
    specify { expect(subject).to match_array(Dummy) }
  end

  describe Rack::Tracker::HandlerSet::Handler do
    subject { described_class.new(Dummy, {foo: 'bar'}) }

    describe '#init' do
      it 'will initialize the handler with the given class' do
        expect(subject.init({})).to be_kind_of(Dummy)
      end

      it 'will initialize the handler with the given options' do
        expect(subject.init({}).options).to eq({foo: 'bar'})
      end
    end
  end

end

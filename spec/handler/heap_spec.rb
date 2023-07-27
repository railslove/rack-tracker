RSpec.describe Rack::Tracker::Heap do
  def env
    { foo: 'bar' }
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq(:head)
    expect(described_class.new(env).position).to eq(:head)
  end

  describe 'user_id tracker option' do
    subject { described_class.new(env, { user_id: user_id }).render }

    let(:user_id) { '123' }

    it 'will include identify call with user_id value' do
      expect(subject).to match(%r{heap.identify\("123"\);})
    end

    context 'when value is a proc' do
      let(:user_id) { proc { '123' } }

      it 'will include identify call with the user_id called value' do
        expect(subject).to match(%r{heap.identify\("123"\);})
      end
    end

    context 'when value is blank' do
      let(:user_id) { '' }

      it 'will not include identify call' do
        expect(subject).not_to match(%r{heap.identify})
      end
    end
  end

  describe 'reset_identity tracker option' do
    subject { described_class.new(env, tracker_options).render }

    let(:tracker_options) do
      { reset_identity: reset_identity? }.compact
    end

    context 'when true' do
      let(:reset_identity?) { true }

      it 'will include resetIdentity call' do
        expect(subject).to match(%r{heap.resetIdentity\(\);})
      end
    end

    context 'when false' do
      let(:reset_identity?) { false }

      it 'will not include resetIdentity call' do
        expect(subject).not_to match(%r{heap.resetIdentity\(\);})
      end
    end

    context 'when not given' do
      let(:reset_identity?) { nil }

      it 'will not include resetIdentity call' do
        expect(subject).not_to match(%r{heap.resetIdentity\(\);})
      end
    end
  end
end

RSpec.describe Rack::Tracker::Handler do
  def env
    { misc: 'foobar' }
  end

  describe '#tracker_options' do
    before do
      stub_const("#{described_class}::ALLOWED_TRACKER_OPTIONS", [:some_option])
    end

    context 'with an allowed option configured with a static value' do
      subject { described_class.new(env, { some_option: 'value' }) }

      it 'returns hash with option set' do
        expect(subject.tracker_options).to eql ({ some_option: 'value' })
      end
    end

    context 'with an allowed option configured with a block' do
      subject { described_class.new(env, { some_option: lambda { |env| return env[:misc] } }) }

      it 'returns hash with option set' do
        expect(subject.tracker_options).to eql ({ some_option: 'foobar' })
      end
    end

    context 'with an allowed option configured with a block returning nil' do
      subject { described_class.new(env, { some_option: lambda { |env| return env[:non_existing_key] } }) }

      it 'returns an empty hash' do
        expect(subject.tracker_options).to eql ({})
      end
    end

    context 'with a non allowed option' do
      subject { described_class.new(env, { new_option: 'value' }) }

      it 'returns an empty hash' do
        expect(subject.tracker_options).to eql ({})
      end
    end
  end
end

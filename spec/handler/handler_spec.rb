RSpec.describe Rack::Tracker::Handler do
  def env
    { misc: 'foobar' }
  end

  describe '#tracker_options' do
    context 'without overriding allowed_tracker_options' do
      subject { described_class.new(env, { some_option: 'value' }) }

      it 'returns an empty hash' do
        expect(subject.tracker_options).to eql ({})
      end
    end

    context 'with overridden allowed_tracker_options' do
      subject do
        handler = described_class.new(env, {
          static_option: 'value',
          dynamic_option: lambda { |env| return env[:misc] },
          dynamic_nil_option: lambda { |env| return env[:non_existent_key] },
          non_allowed_option: 'value'
        })

        handler.allowed_tracker_options =
          [:static_option, :dynamic_option, :dynamic_nil_option]

        handler
      end

      it 'evaluates dynamic options, rejecting nonallowed and nil ones' do
        expect(subject.tracker_options).to eql ({
          static_option: 'value',
          dynamic_option: 'foobar'
        })
      end
    end
  end
end

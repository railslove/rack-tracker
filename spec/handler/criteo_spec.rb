RSpec.describe Rack::Tracker::Criteo do

  describe Rack::Tracker::Criteo::Event do

    subject { described_class.new(event: "viewItem", item: 'P001') }

    describe '#write' do
      specify { expect(subject.write).to eq("{\"event\":\"viewItem\",\"item\":\"P001\"}") }
    end
  end

  def env
    {}
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
    expect(described_class.new(env).position).to eq(:body)
  end

  describe '#render' do
    context 'with events' do
      let(:env) {
        {
          'tracker' => {
          'criteo' =>
            [
              {
                event: 'viewItem',
                item: 'P001',
                class_name: 'Event'
              }
            ]
          }
        }
      }

      subject { described_class.new(env).render }

      it 'will push the tracking events to the queue' do
        expect(subject).to include 'window.criteo_q.push({"event":"viewItem","item":"P001"});'
      end
    end

    context 'without events' do
     let(:env) {
        {
          'tracker' => {
            'criteo' => []
          }
        }
      }

      subject { described_class.new(env, { user_id: ->(env){ '123' } }).render }

      it 'should render nothing' do
        expect(subject).to eql ""
      end
    end
  end

  describe '#tracker_options' do
    describe 'with site_type' do
      context 'returning a value' do
        subject { described_class.new(env, { site_type: ->(env){ 'd' } }) }

        it 'returns hash with userId' do
          expect(subject.tracker_options).to eql ({ site_type: 'd' })
        end
      end

      context 'returning nil' do
        subject { described_class.new(env, { site_type: ->(env){ nil } }) }

        it 'returns hash without userId' do
          expect(subject.tracker_options).to eql ({ })
        end
      end
    end

    describe 'with user_id option' do
      context 'returning a value' do
        subject { described_class.new(env, { user_id: ->(env){ '123' } }) }

        it 'returns hash with userId' do
          expect(subject.tracker_options).to eql ({ user_id: '123' })
        end
      end

      context 'returning nil' do
        subject { described_class.new(env, { user_id: ->(env){ nil } }) }

        it 'returns hash without userId' do
          expect(subject.tracker_options).to eql ({ })
        end
      end
    end
  end

end
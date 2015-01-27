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

  describe '#tracker_events' do
    subject { described_class.new(env, options) }

    context 'nil value' do
      let(:options) = { { set_account: nil } }

      it 'should ignore option' do
        expect(subject.tracker_events).to match_array []
      end
    end

    context 'static string value' do
      let(:options) = { { set_account: '1234' } }

      it 'should set the value' do
        expect(subject.tracker_events).to match_array [
          Rack::Tracker::Criteo::Event.new(event: 'setAccount', account: '1234')
        ]
      end
    end

    context 'static integer value' do
      let(:options) = { { set_customer_id: 1234 } }

      it 'should set the value as string' do
        expect(subject.tracker_events).to match_array [
          Rack::Tracker::Criteo::Event.new(event: 'setCustomerId', id: '1234')
        ]
      end
    end

    context 'unsupported option' do
      let(:options) { unsupported: "option" }

      subject { described_class.new(env, options) }

      it 'should ignore the option' do
        expect(subject.tracker_events).to match_array []
      end
    end

    context 'proc returning value' do
      let(:options) = { { set_site_type: ->(env){ 'm' } } }

      it 'should set the value' do
        expect(subject.tracker_events).to match_array [
          Rack::Tracker::Criteo::Event.new(event: 'setSiteType', type: 'm')
        ]
      end
    end

    context 'proc returning nil' do
      let(:options) = { { set_account: ->(env){ nil } } }

      it 'should ignore the option' do
        expect(subject.tracker_events).to match_array []
      end
    end
  end

end
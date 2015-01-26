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
    subject { described_class.new(env, { set_account: '1234', set_site_type: ->(env){ 'd' }, set_customer_id: ->(env){ nil } }) }

    specify do
      expect(subject.tracker_events).to match_array [
        Rack::Tracker::Criteo::Event.new(event: 'setSiteType', type: 'd'),
        Rack::Tracker::Criteo::Event.new(event: 'setAccount', account: '1234')
      ]
    end
  end

end
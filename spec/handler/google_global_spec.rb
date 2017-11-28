RSpec.describe Rack::Tracker::GoogleGlobal do
  def env
    {
      misc: 'foobar',
      user_id: '123'
    }
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq(:head)
    expect(described_class.new(env).position).to eq(:head)
    expect(described_class.new(env, position: :body).position).to eq(:body)
  end

  describe '#tracker_options' do
    before do
      stub_const("#{described_class}::ALLOWED_TRACKER_OPTIONS", [:some_option])
    end

    context 'with an allowed option configured with a static value' do
      let(:tracker) { { options: { some_option: 'value'} } }
      subject { described_class.new(env, trackers: [tracker]) }

      it 'returns hash with option set' do
        expect(subject.tracker_options(tracker)).to eql ({ some_option: 'value' })
      end
    end

    context 'with an allowed option configured with a block' do
      let(:tracker) { { options: { some_option: lambda { |env| return env[:misc] }}} }
      subject { described_class.new(env, trackers: [tracker]) }

      it 'returns hash with option set' do
        expect(subject.tracker_options(tracker)).to eql ({ some_option: 'foobar' })
      end
    end

    context 'with an allowed option configured with a block returning nil' do
      let(:tracker) { { options: { some_option: lambda { |env| return env[:non_existing_key] } } }}
      subject { described_class.new(env, trackers: [tracker]) }

      it 'returns an empty hash' do
        expect(subject.tracker_options(tracker)).to eql ({})
      end
    end

    context 'with a non allowed option' do
      let(:tracker) { { new_option: 'value' } }
      subject { described_class.new(env, trackers: [tracker]) }

      it 'returns an empty hash' do
        expect(subject.tracker_options(tracker)).to eql ({})
      end
    end
  end

  describe "with custom domain" do
    let(:tracker) { { id: 'somebody', options: { cookie_domain: "railslabs.com" }}}
    subject { described_class.new(env, trackers: [tracker]).render }

    it "will show asyncronous tracker with cookie_domain" do
      expect(subject).to match(%r{gtag\('config', 'somebody', {\"cookie_domain\":\"railslabs.com\"}\)})
    end
  end

  describe "with user_id tracking" do
    let(:tracker) { { id: 'somebody', options: { user_id: lambda { |env| return env[:user_id] } } }}
    subject { described_class.new(env, trackers: [tracker] ).render }

    it "will show asyncronous tracker with userId" do
      expect(subject).to match(%r{gtag\('config', 'somebody', {\"user_id\":\"123\"}\)})
    end
  end

  describe "with link_attribution" do
    let(:tracker) { { id: 'happy', options: { link_attribution: true }}}
    subject { described_class.new(env, trackers: [tracker]).render }

    it "will show asyncronous tracker with link_attribution" do
      expect(subject).to match(%r{gtag\('config', 'happy', {\"link_attribution\":true}\)})
    end
  end

  describe "with allow_display_features" do
    let(:tracker) { { id: 'happy', options: { allow_display_features: false }}}
    subject { described_class.new(env, trackers: [tracker]).render }

    it "will disable display features" do
      expect(subject).to match(%r{gtag\('config', 'happy', {\"allow_display_features\":false}\)})
    end
  end

  describe "with anonymizeIp" do
    let(:tracker) { { id: 'happy', options: { anonymize_ip: true } } } 
    subject { described_class.new(env, trackers: [tracker]).render }

    it "will set anonymizeIp to true" do
      expect(subject).to match(%r{gtag\('config', 'happy', {\"anonymize_ip\":true}\)})
    end
  end

  describe "with dynamic tracker" do
    let(:tracker) { {id: lambda { |env| return env[:misc] } }}
    subject { described_class.new(env, trackers: [tracker]).render }

    it 'will call tracker lambdas to obtain tracking codes' do
      expect(subject).to match(%r{gtag\('config', 'foobar', {}\)})
    end
  end
end

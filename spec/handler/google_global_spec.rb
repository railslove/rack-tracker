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
    context 'with an allowed option configured with a static value' do
      subject { described_class.new(env, user_id: 'value') }

      it 'returns hash with option set' do
        expect(subject.tracker_options).to eql ({ user_id: 'value' })
      end
    end

    context 'with an allowed option configured with a block' do
      subject { described_class.new(env, user_id: lambda { |env| return env[:misc] }) }

      it 'returns hash with option set' do
        expect(subject.tracker_options).to eql ({ user_id: 'foobar' })
      end
    end

    context 'with an allowed option configured with a block returning nil' do
      subject { described_class.new(env, user_id: lambda { |env| return env[:non_existing_key] }) }

      it 'returns an empty hash' do
        expect(subject.tracker_options).to eql ({})
      end
    end

    context 'with a non allowed option' do
      subject { described_class.new(env, new_option: 'value') }

      it 'returns an empty hash' do
        expect(subject.tracker_options).to eql ({})
      end
    end
  end

  describe '#set_options' do
    context 'with option configured with a static value' do
      subject { described_class.new(env, set: { option: 'value' }) }

      it 'returns hash with option set' do
        expect(subject.set_options).to eql ({ option: 'value' })
      end
    end

    context 'with option configured with a block' do
      subject { described_class.new(env, set: lambda { |env| return { option: env[:misc] } }) }

      it 'returns hash with option set' do
        expect(subject.set_options).to eql ({ option: 'foobar' })
      end
    end

    context 'with option configured with a block returning nil' do
      subject { described_class.new(env, set: lambda { |env| return env[:non_existing_key] }) }

      it 'returns nil' do
        expect(subject.set_options).to be nil
      end
    end
  end
  describe "with custom domain" do
    let(:tracker) { { id: 'somebody'}}
    let(:options) { { cookie_domain: "railslabs.com", trackers: [tracker] } }
    subject { described_class.new(env, options).render }

    it "will show asyncronous tracker with cookie_domain" do
      expect(subject).to match(%r{gtag\('config', 'somebody', {\"cookie_domain\":\"railslabs.com\"}\)})
    end
  end

  describe "with user_id tracking" do
    let(:tracker) { { id: 'somebody'}}
    let(:options) { { user_id: lambda { |env| return env[:user_id] }, trackers: [tracker] } }
    subject { described_class.new(env, options).render }

    it "will show asyncronous tracker with userId" do
      expect(subject).to match(%r{gtag\('config', 'somebody', {\"user_id\":\"123\"}\)})
    end
  end

  describe "with link_attribution" do
    let(:tracker) { { id: 'happy'}}
    let(:options) { { link_attribution: true, trackers: [tracker] } }
    subject { described_class.new(env, options).render }

    it "will show asyncronous tracker with link_attribution" do
      expect(subject).to match(%r{gtag\('config', 'happy', {\"link_attribution\":true}\)})
    end
  end

  describe "with allow_display_features" do
    let(:tracker) { { id: 'happy'}}
    let(:options) { { allow_display_features: false, trackers: [tracker] } }
    subject { described_class.new(env, options).render }

    it "will disable display features" do
      expect(subject).to match(%r{gtag\('config', 'happy', {\"allow_display_features\":false}\)})
    end
  end

  describe "with anonymizeIp" do
    let(:tracker) { { id: 'happy'}}
    let(:options) { { anonymize_ip: true, trackers: [tracker] } }
    subject { described_class.new(env, options).render }

    it "will set anonymizeIp to true" do
      expect(subject).to match(%r{gtag\('config', 'happy', {\"anonymize_ip\":true}\)})
    end
  end

  describe "with dynamic tracker" do
    let(:tracker) { { id: lambda { |env| return env[:misc] } }}
    let(:options) { { trackers: [tracker] } }
    subject { described_class.new(env, options).render }

    it 'will call tracker lambdas to obtain tracking codes' do
      expect(subject).to match(%r{gtag\('config', 'foobar', {}\)})
    end
  end

  describe "with empty tracker" do
    let(:present_tracker) { { id: 'present' }}
    let(:empty_tracker) { { id: lambda { |env| return } }}
    let(:options) { { trackers: [present_tracker, empty_tracker] } }
    subject { described_class.new(env, options).render }

    it 'will not render config' do
      expect(subject).to match(%r{gtag\('config', 'present', {}\)})
      expect(subject).not_to match(%r{gtag\('config', '', {}\)})
    end
  end

  describe "with set options" do
    let(:tracker) { { id: 'with_options' } }
    let(:options) { { trackers: [tracker], set: { foo: 'bar' } } }
    subject { described_class.new(env, options).render }

    it 'will show set command' do
      expect(subject).to match(%r{gtag\('set', {\"foo\":\"bar\"}\)})
    end
  end

  describe "with virtual pages" do
    subject { described_class.new(env, trackers: [{ id: 'somebody' }]).render }

    describe "default" do
      def env
        {'tracker' => {
          'google_global' => [
            { 'class_name' => 'Page', 'path' => '/virtual_page' }
          ]
        }}
      end

      it "will show virtual page" do
        expect(subject).to match(%r{gtag\('config', 'somebody', {\"page_path\":\"/virtual_page\"}\);})
      end
    end

    describe "with a event value" do
      def env
        {'tracker' => {
          'google_global' => [
            { 'class_name' => 'Page', 'path' => '/virtual_page', 'location' => 'https://example.com/virtual_page', 'title' => 'Virtual Page' }
          ]
        }}
      end

      it "will show virtual page" do
        expect(subject).to match(%r{gtag\('config', 'somebody', {\"page_title\":\"Virtual Page\",\"page_location\":\"https:\/\/example.com\/virtual_page\",\"page_path\":\"/virtual_page\"}\);})
      end
    end
  end
end

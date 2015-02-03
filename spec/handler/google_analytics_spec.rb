RSpec.describe Rack::Tracker::GoogleAnalytics do

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

  describe '#ecommerce_events' do
    subject { described_class.new(env) }

    describe 'with stored ecommerce events' do
      before { allow(subject).to receive(:events).and_return([Rack::Tracker::GoogleAnalytics::Send.new, Rack::Tracker::GoogleAnalytics::Ecommerce.new]) }

      it 'will just return the ecommerce events' do
        expect(subject.ecommerce_events).to match_array(Rack::Tracker::GoogleAnalytics::Ecommerce)
      end
    end

    describe 'without stored ecommerce events' do
      before { allow(subject).to receive(:events).and_return([Rack::Tracker::GoogleAnalytics::Send.new]) }

      it 'will be empty' do
        expect(subject.ecommerce_events).to be_empty
      end
    end
  end

  describe '#tracker_options' do
    before do
      stub_const("#{described_class}::ALLOWED_TRACKER_OPTIONS", [:some_option])
    end

    context 'with an allowed option configured with a static value' do
      subject { described_class.new(env, { some_option: 'value' }) }

      it 'returns hash with option set' do
        expect(subject.tracker_options).to eql ({ someOption: 'value' })
      end
    end

    context 'with an allowed option configured with a block' do
      subject { described_class.new(env, { some_option: lambda { |env| return env[:misc] } }) }

      it 'returns hash with option set' do
        expect(subject.tracker_options).to eql ({ someOption: 'foobar' })
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

  describe "with events" do
    describe "default" do
      def env
        {'tracker' => {
          'google_analytics' => [
            { 'class_name' => 'Send', 'category' => 'Users', 'action' => 'Login', 'label' => 'Standard' }
          ]
        }}
      end

      subject { described_class.new(env, tracker: 'somebody').render }
      it "will show events" do
        expect(subject).to match(%r{ga\(\"send\",{\"hitType\":\"event\",\"eventCategory\":\"Users\",\"eventAction\":\"Login\",\"eventLabel\":\"Standard\"}\)})
      end
    end

    describe "with a event value" do
      def env
        {'tracker' => { 'google_analytics' => [
          { 'class_name' => 'Send', category: "Users", action: "Login", label: "Standard", value: "5" }
        ]}}
      end

      subject { described_class.new(env, tracker: 'somebody').render }
      it "will show events with values" do
        expect(subject).to match(%r{ga\(\"send\",{\"hitType\":\"event\",\"eventCategory\":\"Users\",\"eventAction\":\"Login\",\"eventLabel\":\"Standard\",\"eventValue\":\"5\"}\)},)
      end
    end
  end

  describe 'with e-commerce events' do
    describe "default" do
      def env
        {'tracker' => {
          'google_analytics' => [
            { 'class_name' => 'Ecommerce', 'type' => 'addItem', 'id' => '1234', 'name' => 'Fluffy Pink Bunnies', 'sku' => 'DD23444', 'category' => 'Party Toys', 'price' => '11.99', 'quantity' => '1' },
            { 'class_name' => 'Ecommerce', 'type' => 'addTransaction', 'id' => '1234', 'affiliation' => 'Acme Clothing', 'revenue' => 11.99, 'shipping' => '5', 'tax' => '1.29', 'currency' => 'EUR' }
          ]
        }}
      end

      subject { described_class.new(env, tracker: 'somebody', ecommerce: true).render }
      it "will add items" do
        expect(subject).to match(%r{ga\(\"ecommerce:addItem\",#{{id: '1234', name: 'Fluffy Pink Bunnies', sku: 'DD23444', category: 'Party Toys', price: '11.99', quantity: '1'}.to_json}})
      end
      it "will add transaction" do
        expect(subject).to match(%r{ga\(\"ecommerce:addTransaction\",#{{id: '1234', affiliation: 'Acme Clothing', revenue: '11.99', shipping: '5', tax: '1.29', currency: 'EUR'}.to_json}})
      end
      it "will submit cart" do
        expect(subject).to match(%r{ga\('ecommerce:send'\);})
      end
    end
  end

  describe "with custom domain" do
    subject { described_class.new(env, tracker: 'somebody', cookie_domain: "railslabs.com").render }

    it "will show asyncronous tracker with cookieDomain" do
      expect(subject).to match(%r{ga\('create', 'somebody', {\"cookieDomain\":\"railslabs.com\"}\)})
      expect(subject).to match(%r{ga\('send', 'pageview'\)})
    end
  end

  describe "with user_id tracking" do
    subject { described_class.new(env, tracker: 'somebody', user_id: lambda { |env| return env[:user_id] } ).render }

    it "will show asyncronous tracker with userId" do
      expect(subject).to match(%r{ga\('create', 'somebody', {\"userId\":\"123\"}\)})
      expect(subject).to match(%r{ga\('send', 'pageview'\)})
    end
  end

  describe "with enhanced_link_attribution" do
    subject { described_class.new(env, tracker: 'happy', enhanced_link_attribution: true).render }

    it "will embedded the linkid plugin script" do
      expect(subject).to match(%r{linkid.js})
    end
  end

  describe "with advertising" do
    subject { described_class.new(env, tracker: 'happy', advertising: true).render }

    it "will require displayfeatures" do
      expect(subject).to match(%r{ga\('require', 'displayfeatures'\)})
    end
  end

  describe "with e-commerce" do
    subject { described_class.new(env, tracker: 'happy', ecommerce: true).render }

    it "will require the ecommerce plugin" do
      expect(subject).to match(%r{ga\('require', 'ecommerce', 'ecommerce\.js'\)})
    end
  end

  describe "with anonymizeIp" do
    subject { described_class.new(env, tracker: 'happy', anonymize_ip: true).render }

    it "will set anonymizeIp to true" do
      expect(subject).to match(%r{ga\('set', 'anonymizeIp', true\)})
    end
  end

  describe "with dynamic tracker" do
    subject { described_class.new(env, { tracker: lambda { |env| return env[:misc] }}).render }

    it 'will call tracker lambdas to obtain tracking codes' do
      expect(subject).to match(%r{ga\('create', 'foobar', {}\)})
    end
  end

  describe 'adjusted bounce rate' do
    subject { described_class.new(env, tracker: 'afake', adjusted_bounce_rate_timeouts: [15, 30]).render }

    it "will add timeouts to push read events" do
      expect(subject).to match(%r{ga\('send', 'event', '15_seconds', 'read'\)})
      expect(subject).to match(%r{ga\('send', 'event', '30_seconds', 'read'\)})
    end
  end

end

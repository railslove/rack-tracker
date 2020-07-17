RSpec.describe Rack::Tracker::GoogleTagManager do

  def env
    {
      misc: 'foobar',
      user_id: '123'
    }
  end

  describe "with events" do
    describe "default" do
      def env
        {'tracker' => {
          'google_tag_manager' => [
            { 'class_name' => 'Push', 'page' => 'Cart', 'price' => 50, 'content_ids' => ['sku_1', 'sku_2', 'sku_3'] }
          ]
        }}
      end

      subject { described_class.new(env, container: 'somebody').render_head }
      it "will show events" do
        expect(subject).to match(%r{"page":"Cart","price":50,"content_ids":\["sku_1","sku_2","sku_3"\]})
      end
    end
  end

  describe "with dynamic tracker" do
    subject { described_class.new(env, { container: lambda { |env| return env[:misc] }}).render_head }

    it 'will call tracker lambdas to obtain tracking codes' do
      expect(subject).to match(%r{\(window,document,'script','dataLayer','foobar'\)})
    end
  end

  describe '#inject' do
    subject { handler_object.inject(example_response) }
    let(:handler_object) { described_class.new(env, container: 'somebody') }

    before do
      allow(handler_object).to receive(:render_head).and_return('<script>"HEAD"</script>')
      allow(handler_object).to receive(:render_body).and_return('<script>"BODY"</script>')
    end

    context 'with one line html response' do
      let(:example_response) { "<html><head></head><body></body></html>" }

      it 'will have render_head content in head tag' do
        expect(subject).to match(%r{<head>.*<script>"HEAD"</script>.*</head>})
      end

      it 'will have render_body content in body tag' do
        expect(subject).to match(%r{<body>.*<script>"BODY"</script>.*</body>})
      end

    end
  end

end

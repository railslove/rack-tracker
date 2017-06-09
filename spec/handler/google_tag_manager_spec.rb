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

end

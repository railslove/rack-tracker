RSpec.describe Rack::Tracker::GoogleTagManager do

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

  describe "with events" do
    describe "default" do
      def env
        {'tracker' => {
          'google_tag_manager' => [
            { 'class_name' => 'Push', 'name' => 'page', 'value' => 'Cart' },
            { 'class_name' => 'Push', 'name' => 'price', 'value' => 50 }
          ]
        }}
      end

      subject { described_class.new(env, tracker: 'somebody').render }
      it "will show events" do
        expect(subject).to match(%r{'page': 'Cart', 'price': '50'})
      end
    end
  end

  describe "with dynamic tracker" do
    subject { described_class.new(env, { tracker: lambda { |env| return env[:misc] }}).render }

    it 'will call tracker lambdas to obtain tracking codes' do
      expect(subject).to match(%r{\(window,document,'script','dataLayer','foobar'\)})
    end
  end

end

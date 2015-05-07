RSpec.describe Rack::Tracker::GoogleTagManager do

  def env
    {
      misc: 'foobar',
      user_id: '123'
    }
  end

  it 'will be placed in the body by default' do
    expect(described_class.position).to eq({ body: :prepend })
    expect(described_class.new(env).position).to eq({ body: :prepend })
    expect(described_class.new(env, position: { head: :append }).position).to eq({ head: :append })
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

      subject { described_class.new(env, container: 'somebody').render }
      it "will show events" do
        expect(subject).to match(%r{'page': 'Cart', 'price': '50'})
      end
    end
  end

  describe "with dynamic container" do
    subject { described_class.new(env, { container: lambda { |env| return env[:misc] }}).render }

    it 'will call container lambdas to obtain container codes' do
      expect(subject).to match(%r{\(window,document,'script','dataLayer','foobar'\)})
    end
  end

end

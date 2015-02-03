RSpec.describe Rack::Tracker::GoogleAdwordsConversion do

  def env
    {
      misc: 'foobar',
      user_id: '123'
    }
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
    expect(described_class.new(env).position).to eq(:body)
    expect(described_class.new(env, position: :body).position).to eq(:body)
  end

  describe "with events" do
    describe "default" do
      def env
        {'tracker' => {
          'google_adwords_conversion' => [
            { 'class_name' => 'Conversion', 'id' => 123456, 'language' => 'en', 'format' => '3', 'color' => 'ffffff', 'label' => 'Conversion Label' }
          ]
        }}
      end

      subject { described_class.new(env, tracker: 'somebody').render }
      it 'will show events' do
        expect(subject).to match(%r{var google_conversion_id = 123456;\n\s*var google_conversion_language = 'en';\n\s*var google_conversion_format = '3';\n\s*var google_conversion_color = 'ffffff';\n\s*var google_conversion_label = 'Conversion Label';})
        expect(subject).to match(%r{<img.*src=\"\/\/www.googleadservices.com\/pagead\/conversion\/123456\/\?label=Conversion%20Label&amp;guid=ON&amp;script=0\"/>})
      end
    end
  end

end

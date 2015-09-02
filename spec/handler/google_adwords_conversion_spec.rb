RSpec.describe Rack::Tracker::GoogleAdwordsConversion do

  def env
    {
      misc: 'foobar',
      user_id: '123'
    }
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq({ body: :append })
    expect(described_class.new(env).position).to eq({ body: :append })
    expect(described_class.new(env, position: { head: :append }).position).to eq({ head: :append })
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

      subject { described_class.new(env).render }
      it 'will show events' do
        expect(subject).to match(%r{var google_conversion_id = 123456;})
        expect(subject).to match(%r{var google_conversion_language = 'en';})
        expect(subject).to match(%r{var google_conversion_format = '3';})
        expect(subject).to match(%r{var google_conversion_color = 'ffffff';})
        expect(subject).to match(%r{var google_conversion_label = 'Conversion Label';})
        expect(subject).to match(%r{<img.*src=\"\/\/www.googleadservices.com\/pagead\/conversion\/123456\/\?label=Conversion%20Label&amp;guid=ON&amp;script=0\"/>})
      end
    end
  end

  describe 'with options' do
    context 'when there are no params for the handler' do
      let(:options) { { id: 123456,
                        language: 'en',
                        format: '3',
                        color: 'ffffff',
                        label: 'Conversion Label' } }
      let(:env) do
        {
          'tracker' => {
            'google_adwords_conversion' => [
              { 'class_name' => 'Conversion', 'value' => '10.0' }
            ]
          }
        }
      end

      subject { described_class.new(env, options).render }

      it 'will show events by using default options' do
        expect(subject).to match(%r{var google_conversion_id = 123456;})
        expect(subject).to match(%r{var google_conversion_language = 'en';})
        expect(subject).to match(%r{var google_conversion_format = '3';})
        expect(subject).to match(%r{var google_conversion_color = 'ffffff';})
        expect(subject).to match(%r{var google_conversion_label = 'Conversion Label';})
        expect(subject).to match(%r{var google_conversion_value = 10.0;})
        expect(subject).to match(%r{<img.*src=\"\/\/www.googleadservices.com\/pagead\/conversion\/123456\/\?label=Conversion%20Label&amp;guid=ON&amp;script=0\"/>})
      end
    end
  end
end

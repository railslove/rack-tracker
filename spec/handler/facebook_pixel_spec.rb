RSpec.describe Rack::Tracker::FacebookPixel do
  def env
    {}
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
    expect(described_class.new(env).position).to eq(:body)
  end

  describe 'with id' do
    subject { described_class.new(env, id: 'PIXEL_ID').render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{fbq\('init', 'PIXEL_ID'\)})
    end

    it 'will add the noscript fallback' do
      expect(subject).to match(%r{https://www.facebook.com/tr\?id=PIXEL_ID&ev=PageView&noscript=1})
    end
  end

  describe 'with events' do
    def env
      {
        'tracker' => {
        'facebook_pixel' =>
          [
            {
              'type' => 'Purchase',
              'class_name' => 'Track',
              'options' =>
                {
                  'value' => '23',
                  'currency' => 'EUR'
                }
            },{
              'type' => 'FrequentShopper',
              'class_name' => 'TrackCustom',
              'options' =>
                {
                  'purchases' => 8,
                  'category' => 'Sport'
                }
            }
          ]
        }
      }
    end
    subject { described_class.new(env).render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{"track", "Purchase", \{"value":"23","currency":"EUR"\}})
      expect(subject).to match(%r{"trackCustom", "FrequentShopper", \{"purchases":8,"category":"Sport"\}})
    end

    it 'will add the noscript fallback' do
      expect(subject).to match(%r{https://www.facebook.com/tr\?id=&ev=PageView&noscript=1})
    end
  end
end

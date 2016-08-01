RSpec.describe Rack::Tracker::FacebookPixel do
  # describe Rack::Tracker::FacebookPixel::Event do

  #   subject { described_class.new({id: 'id', foo: 'bar'}) }

  #   describe '#write' do
  #     specify { expect(subject.write).to eq(['track', 'id', {foo: 'bar'}].to_json) }
  #   end
  # end

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
              'class_name' => 'Event',
              'options' =>
                {
                  'value' => '23',
                  'currency' => 'EUR'
                }
            }
          ]
        }
      }
    end
    subject { described_class.new(env).render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{"track", "Purchase", \{"value":"23","currency":"EUR"\}})
    end

    it 'will add the noscript fallback' do
      pp subject
      expect(subject).to match(%r{https://www.facebook.com/tr\?id=&ev=PageView&noscript=1})
    end
  end
end

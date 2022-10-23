RSpec.describe Rack::Tracker::TiktokPixel do
  def env
    { 'PIXEL_ID' => 'DYNAMIC_PIXEL_ID' }
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
    expect(described_class.new(env).position).to eq(:body)
  end

  describe 'with static id' do
    subject { described_class.new(env, id: 'PIXEL_ID').render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{ttq\.load\('PIXEL_ID'\)})
    end
  end

  describe 'with dynamic id' do
    subject { described_class.new(env, id: lambda { |env| env['PIXEL_ID'] }).render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{ttq\.load\('DYNAMIC_PIXEL_ID'\)})
    end
  end
end

RSpec.describe Rack::Tracker::Hotjar do
  def env
    { foo: 'bar' }
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq(:head)
    expect(described_class.new(env).position).to eq(:head)
  end
end

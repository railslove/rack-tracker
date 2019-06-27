RSpec.describe Rack::Tracker::Hubspot do

  def env
    { misc: '42' }
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq(:head)
    expect(described_class.new(env).position).to eq(:head)
  end
end

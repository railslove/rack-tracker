RSpec.describe Rack::Tracker::Vwo do

  def env
    {misc: 'foobar'}
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq(:head)
    expect(described_class.new(env).position).to eq(:head)
  end

end

RSpec.describe Rack::Tracker::Vwo do

  def env
    {misc: 'foobar'}
  end

  it 'will be placed in the head' do
    expect(described_class.container_tag).to eq(:head)
    expect(described_class.new(env).container_tag).to eq(:head)
  end

end

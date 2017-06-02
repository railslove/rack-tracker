RSpec.describe Rack::Tracker::Vwo do

  def env
    {misc: 'foobar'}
  end

  it 'will be placed in the head' do
    expect(described_class.new(env).positions.keys.first).to eq(:before_head_close)
  end

end

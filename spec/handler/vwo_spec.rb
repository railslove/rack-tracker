RSpec.describe Rack::Tracker::Vwo do

  def env
    {misc: 'foobar'}
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq({ head: :append })
    expect(described_class.new(env).position).to eq({ head: :append })
    expect(described_class.new(env, position: { body: :append }).position).to eq({ body: :append })
  end

end

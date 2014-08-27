Foo = Class.new
Bar = Class.new

RSpec.describe Rack::Tracker::HandlerDelegator do

  describe '#handler' do

    it 'will find handler in the Rack::Tracker namespace' do
      expect(described_class.handler(:google_analytics)).to eq(Rack::Tracker::GoogleAnalytics)
    end

    it 'will find handler outside the Rack::Tracker namespace' do
      expect(described_class.handler(:foo)).to eq(Foo)
    end

    it 'will just return a class' do
      expect(described_class.handler(Bar)).to eq(Bar)
    end

    it 'will raise when no handler is found' do
      expect { described_class.handler(:baz)}.to raise_error(ArgumentError, "No such Handler: Baz")
    end

  end

end

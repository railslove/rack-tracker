RSpec.describe Rack::Tracker do

  let(:escaper) do
    Class.new { include Rack::Tracker::JavaScriptHelper }.new
  end

  subject { escaper }

  # Instance methods are mixed in
  it { should respond_to :escape_javascript }
  it { should respond_to :j }

  context 'with plain values' do
    it 'should return untouched values' do
      expect(escaper.j('Hello')).to eq 'Hello'
    end
  end

  # The following is a RSpec port of original rails's test suite for #j method.
  # https://github.com/rails/rails/blob/master/actionview/test/template/javascript_helper_test.rb
  describe '#escape_javascript' do

    # Simple matcher to shorten specs
    matcher :escape do |value|

      match do |actual|
        raise ArgumentError, 'macther syntax is escape("some value").to("expected value")' unless @expected
        actual.j(value) == @expected
      end

      # Syntactic sugar for matcher
      chain :to do |to|
        @expected = to
        self
      end
    end

    it { should escape(nil).to '' }
    it { should escape(%(This "thing" is really\n netos')).to %(This \\"thing\\" is really\\n netos\\') }
    it { should escape(%(backslash\\test)).to %(backslash\\\\test) }
    it { should escape(%(dont </close> tags)).to %(dont <\\/close> tags) }
    it { should escape(%(unicode \342\200\250 newline).force_encoding(Encoding::UTF_8).encode!).to %(unicode &#x2028; newline) }
    it { should escape(%(unicode \342\200\251 newline).force_encoding(Encoding::UTF_8).encode!).to %(unicode &#x2029; newline) }

  end

end
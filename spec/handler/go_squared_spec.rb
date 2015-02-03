RSpec.describe Rack::Tracker::GoSquared do

  def env
    {misc: 'foobar'}
  end

  it 'will be placed in the head' do
    expect(described_class.position).to eq(:head)
    expect(described_class.new(env).position).to eq(:head)
  end

  describe "with events" do
    describe "visitor name" do
      def env
        {'tracker' => {
          'go_squared' => [
            { 'class_name' => 'VisitorName', 'name' => 'John Doe' }
          ]
        }}
      end

      subject { described_class.new(env, tracker: '12345').render }

      it "will show the right name" do
        expect(subject).to match(%r{_gs\(\"set\",\"visitorName\",\"John Doe\"\)})
      end
    end

    describe "visitor details" do
      def env
        {'tracker' => {
          'go_squared' => [
            { 'class_name' => 'VisitorInfo', 'age' => 35, 'favorite_food' => 'pizza' }
          ]
        }}
      end

      subject { described_class.new(env, tracker: '12345').render }

      it "will show the right properties" do
        expect(subject).to match(%r{_gs\(\"set\",\"visitor\",{\"age\":35,\"favorite_food\":\"pizza\"}\)})
      end
    end
  end

end

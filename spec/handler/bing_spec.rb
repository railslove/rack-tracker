RSpec.describe Rack::Tracker::Bing do

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
  end

  describe "with events" do
    subject { described_class.new(env, tracker: 'somebody').render }

    describe "default" do
      def env
        {'tracker' => {
          'bing' => [
            { 'class_name' => 'Conversion', 'category' => 'Users', 'action' => 'Login', 'label' => 'Standard', 'value' => 10 }
          ]
        }}
      end

      it "will show event initialiser" do
        expect(subject).to include "window.uetq = window.uetq || [];"
      end

      it "will show events" do
        expect(subject).to include "window.uetq.push({ 'ec': 'Users', 'ea': 'Login', 'el': 'Standard', 'ev': 10 });"
      end
    end
  end

  describe "with multiple events" do
    subject { described_class.new(env, tracker: 'somebody').render }

    describe "default" do
      def env
        {'tracker' => {
          'bing' => [
            { 'class_name' => 'Conversion', 'category' => 'Users', 'action' => 'Login', 'label' => 'Standard', 'value' => 10 },
            { 'class_name' => 'Conversion', 'category' => 'Users', 'action' => 'Logout', 'label' => 'Standard', 'value' => 5 }
          ]
        }}
      end

      it "will show event initialiser" do
        expect(subject).to include "window.uetq = window.uetq || [];"
      end

      it "will show events" do
        expect(subject).to include "window.uetq.push({ 'ec': 'Users', 'ea': 'Login', 'el': 'Standard', 'ev': 10 });"
        expect(subject).to include "window.uetq.push({ 'ec': 'Users', 'ea': 'Logout', 'el': 'Standard', 'ev': 5 });"
      end
    end
  end

end
TestController = Struct.new(:env) do
  include Rack::Tracker::Controller

  def index
    tracker do |t|
      t.google_analytics category: 'foo'
    end
  end
end


RSpec.describe Rack::Tracker::Controller do
  describe '#tracker' do
    let(:event) { Rack::Tracker::GoogleAnalytics::Event.new(category: 'foo') }
    let(:controller) { TestController.new({}) }

    it 'writes the event into env' do
      expect {
        controller.index
      }.to change {
        controller.env
      }.from({}).to('tracker' => {'google_analytics' => [event]})
    end

    it 'returns only the handlers' do
      expect(
        controller.tracker do |t|
          t.google_analytics category: 'foo'
          t.facebook some: 'thing'
        end
      ).to eql([:google_analytics, :facebook])
    end
  end
end

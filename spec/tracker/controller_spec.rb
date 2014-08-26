class SomeController
  include Rack::Tracker::Controller

  attr_accessor :env

  def initialize
    @env = {}
  end

  def index
    tracker do
      google_analytics category: 'foo'
    end
  end
end


RSpec.describe Rack::Tracker::Controller do
  context 'controller' do
    let(:event) { Rack::Tracker::GoogleAnalytics::Event.new(category: 'foo') }

    it 'writes the event into env' do
      controller = SomeController.new
      expect {
        controller.index
      }.to change {
        controller.env
      }.from({}).to('tracker' => {'google_analytics' => [event]})
    end
  end
end

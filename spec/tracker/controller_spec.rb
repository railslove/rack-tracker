TestController = Struct.new(:env) do
  include Rack::Tracker::Controller

  def index
    tracker do |t|
      t.google_analytics :send, category: 'foo'
    end
  end
end


RSpec.describe Rack::Tracker::Controller do
  describe '#tracker' do
    let(:event) { Rack::Tracker::GoogleAnalytics::Send.new(category: 'foo') }
    let(:controller) { TestController.new({}) }

    context 'controller' do
      it 'writes the event into env' do
        expect {
          controller.index
        }.to change {
          controller.env
        }.from({}).to('tracker' => {'google_analytics' => [event]})
      end
    end
  end
end

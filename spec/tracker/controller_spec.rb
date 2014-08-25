class SomeController
  include Rack::Tracker::Controller

  attr_accessor :env

  def initialize
    @env = {}
  end

  def index
    tracker do
      google_analytics foo: 'bar'
    end
  end
end


RSpec.describe Rack::Tracker::Controller do
  context 'in controller' do
    subject { SomeController.new.index }

    xit "does something" do
      expect(subject).to eql("")
    end
  end
end

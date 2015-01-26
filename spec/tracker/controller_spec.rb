TestController = Struct.new(:env) do
  include Rack::Tracker::Controller

  def index
    tracker do |t|
      t.google_analytics :send, category: 'foo'
      t.google_analytics :ecommerce, {
        type: 'addTransaction',
        some: 'thing'
      }
      %w(foo bar).each do |item|
        t.google_analytics :ecommerce, {
          type: 'addItem',
          name: item
        }
      end
      t.facebook :track, { id: '1', value: 1, currency: 'USD' }
    end
  end
end


RSpec.describe Rack::Tracker::Controller do
  describe '#tracker' do
    let(:send)       { { class_name: 'Send', category: 'foo' } }
    let(:trx)        { { class_name: 'Ecommerce', type: 'addTransaction', some: 'thing' } }
    let(:item_foo)   { { class_name: 'Ecommerce', type: 'addItem', name: 'foo' } }
    let(:item_bar)   { { class_name: 'Ecommerce', type: 'addItem', name: 'bar' } }
    let(:fb_event)   { { class_name: 'Event', id: '1', value: 1, currency: 'USD' } }
    let(:controller) { TestController.new({}) }

    context 'controller' do
      it 'writes the event into env' do
        expect {
          controller.index
        }.to change {
          controller.env
        }.from({}).to('tracker' => {'google_analytics' => [send, trx, item_foo, item_bar], 'facebook' => [fb_event]})
      end
    end
  end
end

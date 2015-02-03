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
    let(:send)       { { 'category' => 'foo', 'class_name' => 'Send' } }
    let(:trx)        { { 'type' => 'addTransaction', 'some' => 'thing', 'class_name' => 'Ecommerce' } }
    let(:item_foo)   { { 'type' => 'addItem', 'name' => 'foo', 'class_name' => 'Ecommerce' } }
    let(:item_bar)   { { 'type' => 'addItem', 'name' => 'bar', 'class_name' => 'Ecommerce' } }
    let(:fb_event)   { { 'id' => '1', 'value' => 1, 'currency' => 'USD', 'class_name' => 'Event' } }
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

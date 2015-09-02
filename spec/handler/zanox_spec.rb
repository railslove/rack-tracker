RSpec.describe Rack::Tracker::Zanox do

  describe Rack::Tracker::Zanox::Sale do

    subject { described_class.new(order_i_d: 'DEFC-4321', currency_symbol: 'EUR', total_price: '150.00') }

    describe '#write' do
      specify { expect(subject.write).to eq "OrderID=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[150.00]]" }
    end
  end

  describe Rack::Tracker::Zanox::Mastertag do

    subject { described_class.new(id: "25GHTE9A07DF67DFG90T", category: 'Swimming', amount: '3.50', products: [{amount: '5', currency: 'EUR'}, {amount: '6', currency: 'USD'}]) }

    describe '#write' do
      specify { expect(subject.write).to eq "var zx_category = \"Swimming\";\nvar zx_amount = \"3.50\";\nvar zx_products = [{\"amount\":\"5\",\"currency\":\"EUR\"},{\"amount\":\"6\",\"currency\":\"USD\"}];"}
    end
  end

  def env
    {}
  end

  it 'will be placed in the body by default' do
    expect(described_class.position).to eq({ body: :append })
    expect(described_class.new(env).position).to eq({ body: :append })
    expect(described_class.new(env, position: { head: :append }).position).to eq({ head: :append })
  end

  describe '#render #sale_events' do
    context 'with events' do
      let(:env) {
        {
          'tracker' => {
          'zanox' =>
            [
              {
                'CustomerID' => '123456',
                'OrderId' => 'DEFC-4321',
                'CurrencySymbol' => 'EUR',
                'TotalPrice' => '150.00',
                'class_name' => 'Sale',
              }
            ]
          }
        }
      }

      subject { described_class.new(env, options).render }
      let(:options) { { account_id: '123456H123456' } }

      it 'will display the correct tracking events' do
        expect(subject).to include "https://ad.zanox.com/pps/?123456H123456&mode=[[1]]&CustomerID=[[123456]]&OrderId=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[150.00]]"
      end
    end
  end

  describe '#render #lead_events' do
    context 'with events' do
      let(:env) {
        {
          'tracker' => {
          'zanox' =>
            [
              {
                'OrderId' => 'DEFC-4321',
                'class_name' => 'Lead'
              }
            ]
          }
        }
      }

      subject { described_class.new(env, options).render }
      let(:options) { { account_id: '123456H123456' } }

      it 'will display the correct tracking events' do
        expect(subject).to include "https://ad.zanox.com/ppl/?123456H123456&mode=[[1]]&OrderId=[[DEFC-4321]]"
      end
    end
  end

  describe '#render a #mastertag event' do
    context 'with events' do
      let(:env) {
        {
          'tracker' => {
          'zanox' =>
            [
              {
                'id' => '12345678D2345',
                'class_name' => 'Mastertag',
                'category' => 'Sewing',
                'identifier' => '234',
                'amount' => '5.90'
              }
            ]
          }
        }
      }

      subject { described_class.new(env, options).render }

      let(:options) { { account_id: '123456H123456' } }

      it 'will display the correct tracking events' do
        expect(subject).to include 'window._zx.push({"id": "12345678D2345"});'
        expect(subject).to include "var zx_category = \"Sewing\";\nvar zx_identifier = \"234\";\nvar zx_amount = \"5.90\";\n"
      end
    end
  end
end

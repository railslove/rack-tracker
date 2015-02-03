require 'support/capybara_app_helper'

RSpec.describe "Criteo Integration" do
  before do
    setup_app(action: :criteo) do |tracker|
      tracker.handler(:criteo, {
        set_account: '1234',
        set_customer_id: ->(env){ '4711' },
        set_site_type: ->(env){ 'm' }
      })
    end
    visit '/'
  end

  subject { page }

  it 'should include all the events' do
    # tracker_events
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"setAccount\",\"account\":\"1234\"});"
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"setSiteType\",\"type\":\"m\"});"
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"setCustomerId\",\"id\":\"4711\"});"

    # events
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"viewItem\",\"item\":\"P001\"});"
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"viewList\",\"item\":[\"P001\",\"P002\"]});"
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"trackTransaction\",\"id\":\"id\",\"item\":{\"id\":\"P0038\",\"price\":\"6.54\",\"quantity\":1}});"
    expect(page.find("body")).to have_content "window.criteo_q.push({\"event\":\"viewBasket\",\"item\":[{\"id\":\"P001\",\"price\":\"6.54\",\"quantity\":1},{\"id\":\"P0038\",\"price\":\"2.99\",\"quantity\":1}]});"
  end

  describe 'adjust tracker position via options' do
    before do
      setup_app(action: :criteo) do |tracker|
        tracker.handler :criteo, { set_account: '1234', position: :head }
      end
      visit '/'
    end

    it "will be placed in the specified tag" do
     expect(page.find("body")).to_not have_content('criteo')
     expect(page.find("head")).to have_content("{\"event\":\"setAccount\",\"account\":\"1234\"}")
    end

  end
end

require 'support/capybara_app_helper'

RSpec.describe "Criteo Integration" do
  before do
    setup_app(action: :criteo) do |tracker|
      tracker.handler(:criteo, {
        account_id: '1234',
        user_id: ->(env){ '4711' },
        site_type: ->(env) { 'm' }
      })
    end
    visit '/'
  end

  subject { page }

  it 'should include all the basic pushes' do
    expect(page.find("body")).to have_content("window.criteo_q.push({ event: 'setAccount', account: '1234' });")
    expect(page.find("body")).to have_content("window.criteo_q.push({ event: 'setSiteType', type: 'm' });")
    expect(page.find("body")).to have_content("window.criteo_q.push({ event: 'setCustomerId', id: '4711' });")
  end

  describe 'adjust tracker position via options' do
    before do
      setup_app(action: :criteo) do |tracker|
        tracker.handler :criteo, { account_id: '1234', position: :head }
      end
      visit '/'
    end

    it "will be placed in the specified tag" do
     expect(page.find("body")).to_not have_content('criteo')
     expect(page.find("head")).to have_content("{ event: 'setAccount', account: '1234' }")
    end

  end
end

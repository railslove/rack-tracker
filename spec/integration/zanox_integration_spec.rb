require 'support/capybara_app_helper'

RSpec.describe "Zanox Integration" do

  before do
    setup_app(action: :zanox) do |tracker|
      tracker.handler(:zanox, { account_id: '12345H123456789' } )
    end

    visit '/'
  end

  subject { page }

  it 'should include the mastertag event' do
    expect(page.find("body")).to have_content "window._zx.push({\"id\": \"blurg567\"});"
  end

  it 'should include the track event' do
    expect(page).to have_xpath "//script[contains(@src,'zan/?12345H123456789&mode=[[1]]&CustomerID=[[123456]]&OrderID=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[150.00]]')]"
  end
end

# frozen_string_literal: true

require 'support/capybara_app_helper'

RSpec.describe 'Zanox Integration' do
  before do
    setup_app(action: :zanox) do |tracker|
      tracker.handler(:zanox, { account_id: '12345H123456789' })
    end

    visit '/'
  end

  subject { page }

  it 'includes the mastertag event' do
    expect(page.find('body')).to have_content 'window._zx.push({"id": "blurg567"});'
    expect(page).to have_content "var zx_category = \"cake decorating\";\nvar zx_amount = \"5.90\";\n"
  end

  it 'includes the sale event' do
    expect(page).to have_xpath "//script[contains(@src,'pps/?12345H123456789&mode=[[1]]&CustomerID=[[123456]]&OrderID=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[150.00]]')]"
  end

  it 'includes the lead event' do
    expect(page).to have_xpath "//script[contains(@src,'ppl/?12345H123456789&mode=[[1]]&CustomerID=[[654321]]')]"
  end
end

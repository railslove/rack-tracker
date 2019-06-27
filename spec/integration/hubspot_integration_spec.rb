require 'support/capybara_app_helper'

RSpec.describe "Hubspot Integration" do
  before do
    setup_app(action: :hubspot) do |tracker|
      tracker.handler :hubspot, { site_id: '123456' }
    end

    visit '/'
  end


  subject { page }

  it "embeds the site-specifc script tag" do
    expect(page).to have_xpath("//script", id: "hs-script-loader" )
    expect(page.find("script")[:src]).to eq("//js.hs-scripts.com/123456.js")
  end
end

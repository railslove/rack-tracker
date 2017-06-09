require 'support/capybara_app_helper'

RSpec.describe "Google Tag Manager Integration" do
  before do
    setup_app(action: :google_tag_manager) do |tracker|
      tracker.handler :google_tag_manager, { container: 'GTM-ABCDEF' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page.find("head")).to have_content 'GTM-ABCDEF'
    expect(page.find("head")).to have_content "dataLayer.push( {\"click\":\"X\",\"price\":10}, {\"transactionProducts\":[{\"sku\":\"DD44\",\"name\":\"T-shirt\"},{\"sku\":\"DD66\",\"name\":\"Jeans\"}]} );"
    expect(page.find("body")).to have_xpath '//body/noscript/iframe[@src="https://www.googletagmanager.com/ns.html?id=GTM-ABCDEF"]'
  end

end
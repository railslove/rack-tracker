require 'support/capybara_app_helper'

RSpec.describe "Google Tag Manager Integration" do
  before do
    setup_app(action: :google_tag_manager) do |tracker|
      tracker.handler :google_tag_manager, { container: 'GTM-ABCDEF' }
    end
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    visit '/'
    expect(page.find("head")).to have_content 'GTM-ABCDEF'
    expect(page.find("head")).to have_content "dataLayer.push({\"click\":\"X\",\"price\":10}, {\"transactionProducts\":[{\"sku\":\"DD44\",\"name\":\"T-shirt\"},{\"sku\":\"DD66\",\"name\":\"Jeans\"}]});"
    expect(page.find("body")).to have_xpath '//body/noscript/iframe[@src="https://www.googletagmanager.com/ns.html?id=GTM-ABCDEF"]'
  end

  it "does not inject a dataLayer if no events are set " do
    visit '/?no_events=true'
    expect(page.find("head")).to have_content 'GTM-ABCDEF'
    expect(page.find("head")).to_not have_content "dataLayer.push("
    expect(page.find("body")).to have_xpath '//body/noscript/iframe[@src="https://www.googletagmanager.com/ns.html?id=GTM-ABCDEF"]'
  end

  it "embeds turbolinks and turbo observers if requested" do
    visit '/'
    expect(page.find("head")).to_not have_content "turbolinks:load"
    setup_app(action: :google_tag_manager) do |tracker|
      tracker.handler :google_tag_manager, { container: 'GTM-ABCDEF', turbolinks: true }
    end
    visit '/'
    expect(page.find("head")).to have_content "turbolinks:load"
    expect(page.find("head")).to have_content "turbo:load"
  end
end

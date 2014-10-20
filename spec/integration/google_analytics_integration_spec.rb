require 'support/capybara_app_helper'

RSpec.describe "Facebook Integration" do
  before do
    setup_app(action: :google_analytics) do |tracker|
      tracker.handler :google_analytics, { tracker: 'U-XXX-Y' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page).to have_content('ga("ecommerce:addItem",{"id":"1234","name":"Fluffy Pink Bunnies","sku":"DD23444","category":"Party Toys","price":"11.99","quantity":"1"})')
    expect(page).to have_content('ga("ecommerce:addTransaction",{"id":"1234","affiliation":"Acme Clothing","revenue":"11.99","shipping":"5","tax":"1.29"})')
    expect(page).to have_content('ga("send",{"hitType":"event","eventCategory":"button","eventAction":"click","eventLabel":"nav-buttons","eventValue":"X"})')
  end
end

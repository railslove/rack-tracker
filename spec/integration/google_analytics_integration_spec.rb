require 'support/metal_controller'
require 'support/fake_handler'

RSpec.describe "Facebook Integration" do
  before do
    Capybara.app = Rack::Builder.new do
      use Rack::Tracker do
        handler :google_analytics, { tracker: 'U-XXX-Y' }
      end
      run MetalController.action(:google_analytics)
    end

    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page).to have_content('ga("ecommerce:addItem",{"id":"1234","affiliation":"Acme Clothing","revenue":"11.99","shipping":"5","tax":"1.29"})')
    expect(page).to have_content('ga("send",{"hitType":"event","eventCategory":"button","eventAction":"click","eventLabel":"nav-buttons","eventValue":"X"})')
  end
end

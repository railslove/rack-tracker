require 'support/capybara_app_helper'

RSpec.describe "Facebook Pixel Integration" do
  before do
    setup_app(action: :facebook_pixel) do |tracker|
      tracker.handler :facebook_pixel, { id: 'PIXEL_ID' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page).to have_content("fbq('init', 'PIXEL_ID');")
    expect(page.body).to include('https://www.facebook.com/tr?id=PIXEL_ID&ev=PageView&noscript=1')
  end
end

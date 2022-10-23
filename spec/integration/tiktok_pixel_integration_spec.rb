require 'support/capybara_app_helper'

RSpec.describe "Tiktok Pixel Integration" do
  before do
    setup_app(action: :tiktok_pixel) do |tracker|
      tracker.handler :tiktok_pixel, { id: 'PIXEL_ID' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag from the controller action" do
    expect(page).to have_content("ttq.load('PIXEL_ID');")
  end
end

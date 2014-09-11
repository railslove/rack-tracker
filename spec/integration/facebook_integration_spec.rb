require 'support/capybara_app_helper'

RSpec.describe "Facebook Integration" do
  before do
    setup_app(action: :facebook) do |tracker|
      tracker.handler :facebook, { custom_audience: 'my-audience' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page).to have_content('window._fbq.push(["addPixelId", "my-audience"]);')
    expect(page.body).to include('https://www.facebook.com/tr?id=my-audience&amp;ev=PixelInitialized')
    expect(page).to have_content('window._fbq.push(["track","conversion-event",{"value":"1","currency":"EUR"}]);')
    expect(page.body).to include('https://www.facebook.com/offsite_event.php?id=conversion-event&amp;value=1&amp;currency=EUR')
  end
end

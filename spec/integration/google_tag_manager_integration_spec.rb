require 'support/capybara_app_helper'

RSpec.describe "Google Tag Manager Integration" do
  before do
    setup_app(action: :google_tag_manager) do |tracker|
      tracker.handler :google_tag_manager, { tracker: 'GTM-ABCDEF' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page.find("body")).to have_content('GTM-ABCDEF')
    expect(page.find("body")).to have_content('\'click\': \'X\', \'price\': \'10\'')
  end

end

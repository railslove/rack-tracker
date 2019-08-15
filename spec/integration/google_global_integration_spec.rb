require 'support/capybara_app_helper'

RSpec.describe "Google Global Integration Integration" do
  before do
    setup_app(action: :google_global) do |tracker|
      tracker.handler :google_global, trackers: [{ id: 'U-XXX-Y' }]
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page.find("head")).to have_content('U-XXX-Y')
  end

  describe 'adjust tracker position via options' do
    before do
      setup_app(action: :google_global) do |tracker|
        tracker.handler :google_global, trackers: [{ id: 'U-XXX-Y' }], position: :body
      end
      visit '/'
    end

    it "will be placed in the specified tag" do
     expect(page.find("head")).to_not have_content('U-XXX-Y')
     expect(page.find("body")).to have_content('U-XXX-Y')
    end
  end

  describe "handles empty tracker id" do
    before do
      setup_app(action: :google_global) do |tracker|
        tracker.handler :google_global, trackers: [{ id: nil }, { id: "" }, { id: "  " }]
      end
      visit '/'
    end

    it "does not inject scripts" do
      expect(page.find("head")).not_to have_content("<script async src='https://www.googletagmanager.com/gtag/js?id=")
    end
  end
end

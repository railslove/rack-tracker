require 'support/capybara_app_helper'

RSpec.describe "Google Global Integration Integration" do
  before do
    setup_app(action: :google_global) do |tracker|
      tracker.handler :google_global, tracker_options
    end
    visit '/'
  end

  let(:tracker_options) { { trackers: [{ id: 'U-XXX-Y' }] } }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page.find("head")).to have_content('U-XXX-Y')
  end

  describe 'adjust tracker position via options' do
    let(:tracker_options) { { trackers: [{ id: 'U-XXX-Y' }], position: :body } }

    it "will be placed in the specified tag" do
     expect(page.find("head")).to_not have_content('U-XXX-Y')
     expect(page.find("body")).to have_content('U-XXX-Y')
    end
  end

  describe "handles empty tracker id" do
    let(:tracker_options) { { trackers: [{ id: nil }, { id: "" }, { id: "  " }] } }

    it "does not inject scripts" do
      expect(page.find("head")).to_not have_content("<script async src='https://www.googletagmanager.com/gtag/js?id=")
    end
  end

  describe "callable tracker id" do
    let(:tracker_options) { { trackers: [{ id: proc { "U-XXX-Y" } }] } }

    it "is injected into head with id from proc" do
      expect(page.find("head")).to have_content('U-XXX-Y')
    end
  end
end

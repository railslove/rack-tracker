require 'support/capybara_app_helper'

RSpec.describe "Bing Integration" do
  before do
    setup_app(action: :bing) do |tracker|
      tracker.handler :bing, { tracker: '12345678' }
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracker" do
    expect(page.find("body")).to have_content('var o = {ti: "12345678"};')
  end

end

require 'support/capybara_app_helper'

RSpec.describe "Google Adwords Conversion Integration" do
  before do
    setup_app(action: :google_adwords_conversion) do |tracker|
      tracker.handler :google_adwords_conversion
    end
    visit '/'
  end

  subject { page }

  it "embeds the script tag with tracking event from the controller action" do
    expect(page.find("body")).to have_content("var google_conversion_id = 123456;\nvar google_conversion_language = 'en';\nvar google_conversion_format = '3';\nvar google_conversion_color = 'ffffff';\nvar google_conversion_label = 'Conversion Label';")
    expect(page.find("body")).to have_xpath("//img[@src=\"//www.googleadservices.com/pagead/conversion/123456/?label=Conversion%20Label&guid=ON&script=0\"]")
  end

end

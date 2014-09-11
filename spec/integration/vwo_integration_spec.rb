require 'support/capybara_app_helper'

RSpec.describe "VWO Integration" do
  before do
    setup_app(action: :vwo) do |tracker|
      tracker.handler :vwo, { account_id: '123456' }
    end

    visit '/'
  end

  subject { page }

  it "embeds the script tag" do
    expect(page).to have_content("this.load('//dev.visualwebsiteoptimizer.com/j.php?a='+ '123456'")
  end
end

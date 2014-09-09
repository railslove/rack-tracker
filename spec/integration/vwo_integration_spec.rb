require 'support/metal_controller'
require 'support/fake_handler'

RSpec.describe "VWO Integration" do
  before do
    Capybara.app = Rack::Builder.new do
      use Rack::Tracker do
        handler :vwo, { account_id: '123456' }
      end
      run MetalController.action(:vwo)
    end

    visit '/'
  end

  subject { page }

  it "embeds the script tag" do
    expect(page).to have_content("this.load('//dev.visualwebsiteoptimizer.com/j.php?a='+ '123456'")
  end
end

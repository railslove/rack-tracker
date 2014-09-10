require 'support/metal_controller'
require 'support/fake_handler'

RSpec.describe "GoSquared Integration" do
  def setup_go_squared_app(options = {})
    Capybara.app = Rack::Builder.new do
      use Rack::Tracker do
        handler :go_squared, options
      end
      run MetalController.action(:go_squared)
    end
  end

  subject { page }

  before do
    setup_go_squared_app(
      tracker: '123456',
      anonymize_ip: true,
      cookie_domain: 'domain.com',
      use_cookies: true,
      track_hash: true,
      track_local: true,
      track_params: true
    )
    visit '/'
  end

  it "adds the tracker to the page" do
    expect(page).to have_content("_gs('123456');")
  end

  it "adds the visitorName to the page" do
    expect(page).to have_content('_gs("set","visitorName","John Doe");')
  end

  it "adds the visitor to the page" do
    expect(page).to have_content('_gs("set","visitor",{"age":35,"favorite_food":"pizza"});')
  end

  it "sets anonymizeIp" do
    expect(page).to have_content("_gs('set', 'anonymizeIp', true);")
  end

  it "sets cookieDomain" do
    expect(page).to have_content("_gs('set', 'cookieDomain', 'domain.com');")
  end

  it "sets useCookies" do
    expect(page).to have_content("_gs('set', 'useCookies', true);")
  end

  it "sets trackHash" do
    expect(page).to have_content("_gs('set', 'trackHash', true);")
  end

  it "sets trackLocal" do
    expect(page).to have_content("_gs('set', 'trackLocal', true);")
  end

  it "sets trackParams" do
    expect(page).to have_content("_gs('set', 'trackParams', true);")
  end

  context 'multiple trackers are passed in' do
    before do
      setup_go_squared_app(trackers: {
        primaryTracker: '12345',
        secondaryTracker: '67890'
      })
      visit '/'
    end

    it "adds the tracker to the page" do
      expect(page).to have_content("_gs('12345', 'primaryTracker');")
      expect(page).to have_content("_gs('67890', 'secondaryTracker');")
    end
  end
end

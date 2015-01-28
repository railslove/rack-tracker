require 'support/capybara_app_helper'

RSpec.describe "metrigo Integration" do
  before do
    setup_app(action: :metrigo) do |tracker|
      tracker.handler :metrigo, { shop_id: 1234 }
    end
    visit '/'
  end

  subject { page }

  it "embeds ALL the scripts" do
    expect(page.find('body')).to have_content 'DELIVERY.DataLogger.logHomepage({"shop_id":1234})'
    expect(page.find('body')).to have_content 'DELIVERY.DataLogger.logCategory({"categories":["cat1","cat2"],"shop_id":1234})'
    expect(page.find('body')).to have_content 'DELIVERY.DataLogger.logProduct({"product":{"external_id":42},"shop_id":1234})'
    expect(page.find('body')).to have_content 'DELIVERY.DataLogger.logCart({"products":[{"external_id":42},{"external_id":37}],"shop_id":1234})'
    expect(page.find('body')).to have_content 'DELIVERY.DataLogger.logConversion({"type":"lead","order_id":"a8ad-234q-asdad","source":0,"products":[{"external_id":37}],"shop_id":1234})'
  end
end

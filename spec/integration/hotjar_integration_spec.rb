require 'support/capybara_app_helper'

RSpec.describe "Hotjar Integration" do
  before do
    setup_app(action: :hotjar) do |tracker|
      tracker.handler :hotjar, { site_id: '4711' }
    end

    visit '/'
  end

  subject { page }

  it 'embeds the script with site_id' do
    expect(page).to have_content(/function\(h,o,t,j,a,r\)(.*)4711/)
  end
end

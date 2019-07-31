require 'support/capybara_app_helper'

RSpec.describe 'Drift Integration' do
  before do
    setup_app(action: :drift) do |tracker|
      tracker.handler :drift, account_id: 'DRIFT_ID'
    end

    visit '/'
  end

  subject { page }

  it 'embeds the script with account_id' do
    expect(page.find('script')).to have_content('js.driftt.com')
    expect(page.find('script')).to have_content('drift.load(\'DRIFT_ID\')')
  end
end

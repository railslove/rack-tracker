require 'support/capybara_app_helper'

RSpec.describe "Heap Integration" do
  before do
    setup_app(action: :heap) do |tracker|
      tracker.handler :heap, { env_id: '12341234' }
    end

    visit '/'
  end

  subject { page }

  it 'embeds the script with site_id' do
    expect(page).to have_content('heap.load("12341234");')
  end
end

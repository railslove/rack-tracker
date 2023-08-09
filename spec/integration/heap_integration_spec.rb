require 'support/capybara_app_helper'

RSpec.describe "Heap Integration" do
  before do
    setup_app(action: :heap) do |tracker|
      tracker.handler :heap, options
    end

    visit '/'
  end

  subject { page }

  let(:options) do
    { env_id: '12341234' }
  end

  it 'embeds the script with site_id' do
    expect(page).to have_content('heap.load("12341234");')
  end

  context 'with user_id tracker option' do
    let(:options) do
      { user_id: '345' }
    end

    it 'includes a call to identify' do
      expect(page).to have_content('heap.identify("345");')
    end
  end

  context 'with reset_identity tracker option' do
    let(:options) do
      { reset_identity: true }
    end

    it 'includes a call to resetIdentity' do
      expect(page).to have_content('heap.resetIdentity();')
    end
  end
end

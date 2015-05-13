require 'support/capybara_app_helper'

RSpec.describe "Zanox Integration" do
  before do
    setup_app(action: :zanox) do |tracker|
      tracker.handler(:zanox, { id: '345345' })
    end

    visit '/'
  end

  subject { page }

  it 'should include all the events' do
    # tracker_events
    binding.pry
    expect(page.find("body")).to have_content " "
  end

  describe 'adjust tracker position via options' do
    before do
      setup_app(action: :zanox) do |tracker|
        tracker.handler :zanox, { id: '1234', position: :head }
      end
      visit '/'
    end

    it "will be placed in the specified tag" do
     expect(page.find("body")).to_not have_content('zanox')
    end

  end
end

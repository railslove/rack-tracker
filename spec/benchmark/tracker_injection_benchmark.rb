require 'support/capybara_app_helper'
require 'benchmark'

EXAMPLE_SIZE = 1000

RSpec.describe 'Benchmark' do
  context 'with tracking' do
    before do
      setup_app(action: :turing) do |tracker|
        tracker.handler :track_all_the_things, { custom_key: 'SomeKey123' }
        tracker.handler :another_handler, { custom_key: 'AnotherKey42' }
      end
    end

    it 'embeds the script tag *lightning fast*' do
      Benchmark.bmbm do |bm|
        bm.report 'render page with inject' do
          EXAMPLE_SIZE.times do
            visit '/'

            expect(page.status_code).to eq(200)
            expect(page.response_headers).to eq('Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => '461684')
          end
        end
      end
    end
  end

  context 'w/o tracking' do
    before do
      setup_app(action: :do_not_track_alan) {}
    end

    it 'is for comparison only' do
      Benchmark.bmbm do |bm|
        bm.report 'render page w/o inject' do
          EXAMPLE_SIZE.times do
            visit '/'

            expect(page.status_code).to eq(200)
            expect(page.response_headers).to eq('Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => '461470')
          end
        end
      end
    end
  end
end

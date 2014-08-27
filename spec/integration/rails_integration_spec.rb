require 'support/metal_controller'
require 'support/fake_handler'

RSpec.describe "Rails Integration" do
  before do
    Capybara.app = Rack::Builder.new do
      use Rack::Tracker do
        handler :track_all_the_things, { custom_key: 'SomeKey123' }
        handler :another_handler, { custom_key: 'AnotherKey42' }
      end
      run MetalController.action(:index)
    end

    visit '/'
  end

  subject { page.html.gsub(/^\s*/, '') }

  let(:expected_html) do
    <<-HTML.gsub(/^\s*/, '')
      <html>
        <head>
          <title>Metal Layout</title>
        <script type="text/javascript">
        myAwesomeFunction("tracks", "like", "no-one-else", "SomeKey123");
      </script>
      </head>
        <body>
          <h1>welcome to metal#index</h1>
        <script type="text/javascript">
        anotherFunction("tracks-event-from-down-under", "AnotherKey42");
      </script>
        </body>
      </html>
    HTML
  end

  it "embeds the script tag with tracking event from the controller action" do
    expect(subject).to eql(expected_html)
  end
end

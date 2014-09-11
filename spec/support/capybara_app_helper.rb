require 'support/metal_controller'

# helper to configure the middleware stack with custom handlers
# and capybara app setup for more convenient testing.
# You can use this in your integration spec by placing it in a before block.
#
# Example:
#
# before do
#   setup_app(action: :your_controller_action) do |tracker|
#     tracker.handler :your_new_handler, { custom_tracker_key: 'SomeKey123' }
#   end
# end
#
# By default this dispatches to a metal controller as a simple rack endpoint
# like rails would do, but without booting up a full rails environment.
def setup_app(options={}, &block)
  rack_endpoint     = options[:endpoint] || MetalController
  controller_action = options[:action]

  Capybara.app = Rack::Builder.new do
    use Rack::Tracker do
      block[self]
    end
    run rack_endpoint.action(controller_action)
  end
end

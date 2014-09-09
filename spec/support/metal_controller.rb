require 'action_controller'

class MetalController < ActionController::Metal
  include Rack::Tracker::Controller
  include AbstractController::Rendering
  include ActionView::Layouts
  append_view_path File.join(File.dirname(__FILE__), '../fixtures/views')
  layout 'application'

  def index
    tracker do |t|
      t.track_all_the_things like: 'no-one-else'
      t.another_handler likes: 'you'
    end
    render "metal/index"
  end

  def facebook
    tracker do |t|
      t.facebook :track, { id: 'conversion-event', value: '1', currency: 'EUR' }
    end
    render "metal/index"
  end

  def google_analytics
    tracker do |t|
      t.google_analytics :ecommerce, { type: 'addItem', id: '1234', affiliation: 'Acme Clothing', revenue: '11.99', shipping: '5', tax: '1.29' }
      t.google_analytics :send, { type: 'event', category: 'button', action: 'click', label: 'nav-buttons', value: 'X' }
    end
    render "metal/index"
  end

  def vwo
    render "metal/index"
  end
end

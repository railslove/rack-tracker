require 'action_controller'

class MetalController < ActionController::Metal
  include Rack::Tracker::Controller
  include AbstractController::Rendering

  # depending on the actionpack version the layout code was moved
  if defined?(ActionView::Layouts)
    include ActionView::Layouts # => this is the new and shiny
  else
    include AbstractController::Layouts
  end

  append_view_path File.join(File.dirname(__FILE__), '../fixtures/views')
  layout 'application'

  def turing
    tracker do |t|
      t.track_all_the_things like: 'turing'
      t.another_handler likes: 'turing'
    end
    render "metal/turing", layout: false
  end

  def do_not_track_alan
    render "metal/turing", layout: false
  end

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

  def facebook_pixel
    tracker do |t|
      t.facebook_pixel :track, { type: 'Purchase', options: { value: 42, currency: 'USD' } }
      t.facebook_pixel :track, { type: 'CompleteRegistration', options: { value: 0.75, currency: 'EUR' } }
      t.facebook_pixel :track_custom, { type: 'FrequentShopper', options: { purchases: 24, category: 'Sport' } }
    end
    render "metal/index"
  end

  def google_analytics
    tracker do |t|
      t.google_analytics :ecommerce, { type: 'addTransaction', id: 1234, affiliation: 'Acme Clothing', revenue: 11.99, shipping: 5, tax: 1.29 }
      t.google_analytics :ecommerce, { type: 'addItem', id: 1234, name: 'Fluffy Pink Bunnies', sku: 'DD23444', category: 'Party Toys', price: 11.99, quantity: 1 }
      t.google_analytics :send, { type: 'event', category: 'button', action: 'click', label: 'nav-buttons', value: 'X' }
      t.google_analytics :parameter, dimension1: %q{Some escaped \\'value}
      t.google_analytics :parameter, dimension2: %q{Author's name}
    end
    render "metal/index"
  end

  def google_tag_manager
    unless params[:no_events]
      tracker do |t|
        t.google_tag_manager :push, { click: 'X', price: 10 }
        t.google_tag_manager :push, transactionProducts: [{ sku: 'DD44', name: 'T-shirt' }, { sku: 'DD66', name: 'Jeans' }]
      end
    end
    render "metal/index"
  end

  def google_adwords_conversion
    tracker do |t|
      t.google_adwords_conversion :conversion, { id: 123456, language: 'en', format: '3', color: 'ffffff', label: 'Conversion Label' }
    end
    render "metal/index"
  end

  def vwo
    render "metal/index"
  end

  def go_squared
    tracker do |t|
      t.go_squared :visitor_name, { name: 'John Doe' }
      t.go_squared :visitor_info, { age: 35, favorite_food: 'pizza' }
    end
    render "metal/index"
  end

  def criteo
    tracker do |t|
      t.criteo :view_item, { item: 'P001' }
      t.criteo :view_list, { item: ['P001', 'P002'] }
      t.criteo :track_transaction, { id: 'id', item: { id: "P0038", price:"6.54", quantity:1 } }
      t.criteo :view_basket, { item: [{ id: "P001", price:"6.54", quantity:1 }, { id: "P0038", price:"2.99", quantity:1 }] }
    end
    render 'metal/index'
  end

  def zanox
    tracker do |t|
      t.zanox :mastertag, { id: 'blurg567', category: 'cake decorating', amount: '5.90'}
      t.zanox :sale, { customer_i_d: '123456', order_i_d: 'DEFC-4321', currency_symbol: 'EUR', total_price: '150.00' }
      t.zanox :lead, { customer_i_d: '654321' }
    end
    render 'metal/index'
  end

  def hotjar
    render "metal/index"
  end
end

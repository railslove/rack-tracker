# Rack::Tracker

[![Code Climate](https://codeclimate.com/github/railslove/rack-tracker/badges/gpa.svg)](https://codeclimate.com/github/railslove/rack-tracker) [![Build Status](https://travis-ci.org/railslove/rack-tracker.svg?branch=master)](https://travis-ci.org/railslove/rack-tracker)

## Rationale

Most of the applications we're working on are using some sort of tracking/analytics service,
Google Analytics comes first but its likely that more are added as the project grows.
Normally you'd go ahead and add some partials to your application that will render out the
needed tracking codes. As time passes by you'll find yourself with lots of tracking
snippets, that will clutter your codebase :) When just looking at Analytics there are
solutions like `rack-google-analytics` but they just soley tackle the existence of one
service.

We wanted a solution that ties all services together in one place and offers
an easy interface to drop in new services. This is why we created `rack-tracker`, a
rack middleware that can be hooked up to multiple services and exposing them in a unified
fashion. It comes in two parts, the first one is the actual middleware that you can add
to the middleware stack the second part are the service-handlers that you're going to use
in your application. It's easy to add your own [custom handlers](#custom-handlers),
but to get you started we're shipping support for the following services out of the box:

* [Google Analytics](#google-analytics)
* [Google Tag Manager](#google-tag-manager)
* [Facebook](#facebook)
* [Visual Website Optimizer (VWO)](#visual-website-optimizer-vwo)
* [GoSquared](#gosquared)
* [Criteo](#criteo)
* [Zanox](#zanox)


## Installation

Add this line to your application's Gemfile:

    gem 'rack-tracker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-tracker

## Usage

Add it to your middleware stack

```ruby
config.middleware.use(Rack::Tracker) do
  handler :google_analytics, { tracker: 'U-XXXXX-Y' }
end
````

This will add Google Analytics as a tracking handler.

## Sinatra / Rack

You can even use Rack::Tracker with Sinatra or respectively with every Rack application

Just insert the Tracker in your Rack stack:

```ruby
web = Rack::Builder.new do
  use Rack::Tracker do
    handler :google_analytics, { tracker: 'U-XXXXX-Y' }
  end
  run Sinatra::Web
end

run web
```

Although you cannot use the Rails controller extensions for obvious reasons, its easy
to inject arbitrary events into the request environment.

```ruby
request.env['tracker'] = {
  'google_analytics' => [
    { 'class_name' => 'Send', 'category' => 'Users', 'action' => 'Login', 'label' => 'Standard' }
  ]
}
```

### Google Analytics

* `:anonymize_ip` -  sets the tracker to remove the last octet from all IP addresses, see https://developers.google.com/analytics/devguides/collection/gajs/methods/gaJSApi_gat?hl=de#_gat._anonymizeIp for details.
* `:cookie_domain` -  sets the domain name for the [GATC cookies](https://developers.google.com/analytics/devguides/collection/analyticsjs/domains#implementation). If not set its the website domain, with the www. prefix removed.
* `:user_id` -  defines a proc to set the [userId](https://developers.google.com/analytics/devguides/collection/analyticsjs/user-id). Ex: `user_id: lambda { |env| env['rack.session']['user_id'] }` would return the user_id from the session.
* `:site_speed_sample_rate` - Defines a new sample set size for Site Speed data collection, see https://developers.google.com/analytics/devguides/collection/gajs/methods/gaJSApiBasicConfiguration?hl=de#_gat.GA_Tracker_._setSiteSpeedSampleRate
* `:adjusted_bounce_rate_timeouts` - An array of times in seconds that the tracker will use to set timeouts for adjusted bounce rate tracking. See http://analytics.blogspot.ca/2012/07/tracking-adjusted-bounce-rate-in-google.html for details.
* `:enhanced_link_attribution` - Enables [Enhanced Link Attribution](https://developers.google.com/analytics/devguides/collection/analyticsjs/advanced#enhancedlink).
* `:advertising` - Enables [Display Features](https://developers.google.com/analytics/devguides/collection/analyticsjs/display-features).
* `:ecommerce` - Enables [Ecommerce Tracking](https://developers.google.com/analytics/devguides/collection/analyticsjs/ecommerce).
* `:enhanced_ecommerce` - Enables [Enhanced Ecommerce Tracking](https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce)

#### Events

To issue [Events](https://developers.google.com/analytics/devguides/collection/analyticsjs/events) from the server side just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.google_analytics :send, { type: 'event', category: 'button', action: 'click', label: 'nav-buttons', value: 'X' }
    end
  end
```

It will render the following to the site source:

```javascript
  ga('send', { 'hitType': 'event', 'eventCategory': 'button', 'eventAction': 'click', 'eventLabel': 'nav-buttons', 'value': 'X' })
```

#### Parameters

You can set parameters in your controller too:

```ruby
  def show
    tracker do |t|
      t.google_analytics :parameter, { dimension1: 'pink' }
    end
  end
```

Will render this:

```javascript
  ga('set', 'dimension1', 'pink');
```



#### Enhanced Ecommerce

You can set parameters in your controller:

```ruby
  def show
    tracker do |t|
      t.google_analytics :enhanced_ecommerce, {
        type: 'addItem',
        id: '1234',
        name: 'Fluffy Pink Bunnies',
        sku: 'DD23444',
        category: 'Party Toys',
        price: '11.99',
        quantity: '1'
      }
    end
  end
```

Will render this:

```javascript
  ga("ec:addItem", {"id": "1234", "name": "Fluffy Pink Bunnies", "sku": "DD23444", "category": "Party Toys", "price": "11.99", "quantity": "1"});
```



#### Ecommerce

You can even trigger ecommerce directly from within your controller:

```ruby
  def show
    tracker do |t|
      t.google_analytics :ecommerce, { type: 'addItem', id: '1234', affiliation: 'Acme Clothing', revenue: '11.99', shipping: '5', tax: '1.29' }
    end
  end
```

Will give you this:

```javascript
  ga('ecommerce:addItem', { 'id': '1234', 'affiliation': 'Acme Clothing', 'revenue': '11.99', 'shipping': '5', 'tax': '1.29'  })
```

To load the `ecommerce`-plugin, add some configuration to the middleware initialization.
This is _not_ needed for the above to work, but recommened, so you don't have to
take care of the plugin on your own.

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :google_analytics, { tracker: 'U-XXXXX-Y', ecommerce: true }
  end
````


### Google Tag Manager

Google Tag manager code snippet doesn't support any option other than the container id

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :google_tag_manager, { container: 'GTM-XXXXXX' }
  end
````

#### Data Layer

GTM supports a [dataLayer](https://developers.google.com/tag-manager/devguide#datalayer) for pushing events as well as variables.

To add events or variables to the dataLayer from the server side, just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.google_tag_manager :push, { name: 'price', value: 'X' }
    end
  end
```


### Facebook

* `custom_audience` - adds the [Custom audience](https://developers.facebook.com/docs/reference/ads-api/custom-audience-website-faq) segmentation pixel

#### Conversions

To track [Conversions](https://www.facebook.com/help/435189689870514) from the server side just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.facebook :track, { id: '123456789', value: 1, currency: 'EUR' }
    end
  end
```

Will result in the following:

```javascript
  window._fbq.push(["track", "123456789", {'value': 1, 'currency': 'EUR'}]);
```
### Visual website Optimizer (VWO)
Just integrate the handler with your matching account_id and you will be ready to go

```ruby
  use Rack::Tracker do
    handler :vwo, { account_id: 'YOUR_ACCOUNT_ID' }
  end
```

### GoSquared

To enable GoSquared tracking:

```ruby
config.middleware.use(Rack::Tracker) do
  handler :go_squared, { tracker: 'ABCDEFGH' }
end
````

This will add the tracker to the page like so:

``` javascript
  _gs('ABCDEFGH');
```

You can also set multiple named trackers if need be:

```ruby
config.middleware.use(Rack::Tracker) do
  handler :go_squared, {
    trackers: {
      primaryTracker: 'ABCDEFGH',
      secondaryTracker: '1234567',
    }
  }
end
````

This will add the specified trackers to the page like so:

``` javascript
  _gs('ABCDEFGH', 'primaryTracker');
  _gs('1234567', 'secondaryTracker');
```

You can set [a variety of options](https://www.gosquared.com/developer/tracker/configuration/) by passing the following settings. If you don't set any of the following options, they will be omitted from the rendered code.

* `:anonymize_ip`
* `:cookie_domain`
* `:use_cookies`
* `:track_hash`
* `:track_local`
* `:track_params`

#### Visitor Name

To track the [visitor name](https://www.gosquared.com/developer/tracker/tagging/) from the server side, just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.go_squared :visitor_name, { name: 'John Doe' }
    end
  end
```

It will render the following to the site source:

```javascript
  _gs("set", "visitorName", "John Doe");
```

#### Visitor Properties

To track [visitor properties](https://www.gosquared.com/developer/tracker/tagging/) from the server side, just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.go_squared :visitor_info, { age: 35, favorite_food: 'pizza' }
    end
  end
```

It will render the following to the site source:

```javascript
  _gs("set", "visitor", { "age": 35, "favorite_food": "pizza" });
```

### Criteo

[Criteo](http://www.criteo.com/) retargeting service.

#### Basic configuration

```
config.middleware.use(Rack::Tracker) do
  handler :criteo, { set_account: '1234' }
end
```

Other global criteo handler options are:
* `set_customer_id: 'x'`
* `set_site_type: 'd'` - possible values are `m` (mobile), `t` (tablet), `d` (desktop)

Option values can be either static or dynamic by providing a lambda being reevaluated for each request, e.g. `set_customer_id: lambda { |env| env['rack.session']['user_id'] }`

#### Tracking events

This will track a basic event:

```
def show
  tracker do |t|
    t.criteo :view_item, { item: 'P0001' }
  end
end
```

This will render to the follwing code in the JS:

```
window.criteo_q.push({"event": "viewItem", "item": "P001" });
```

The first argument for `t.criteo` is always the criteo event (e.g. `:view_item`, `:view_list`, `:track_transaction`, `:view_basket`) and the second argument are additional properties for the event.

Another example

```
t.criteo :track_transaction, { id: 'id', item: { id: "P0038", price: "6.54", quantity: 1 } }
```

### Zanox

[Zanox](http://www.zanox.com/us/)

#### Basic Configuration

```
config.middleware.use(Rack::Tracker) do
  handler :zanox, { account_id: '1234' }
end
```

#### Mastertag

This is an example of a mastertag:

```
def show
  tracker do |t|
    t.zanox :mastertag, { id: "25GHTE9A07DF67DFG90T" }
  end
end
```

This will render to the follwing code in the JS:

```
window._zx.push({"id": "25GHTE9A07DF67DFG90T"});
```

#### Conversion tracking

Lead events and sale events use similar text snippets, but different url paths. For example:
`https://foo.zanox.com/abc/?123456789`, where `abc` is the changing url path. This can be set dynamically along with the rest of the parameters by setting the `path_extension`. 

This is an example of a lead event:

```
def show
  tracker do |t|
    t.zanox :track, { order_i_d: 'DEFC-4321', path_extension: 'abc' }
  end
end
```

This is an example of a sale event:

```
def show
  tracker do |t|
    t.zanox :track, { customer_i_d: '123456', order_i_d: 'DEFC-4321', currency_symbol: 'EUR', total_price: '150.00', path_extension: 'def'}
  end
end
```

### Custom Handlers

Tough we give you handlers for a few tracking services right out of the box, you might
be interested adding support for your custom tracking/analytics service.

Writing a handler is straight forward ;) and there are just a couple of methods that
your class needs to implement.

Start with a plain ruby class that inherits from `Rack::Tracker::Handler`

```ruby
class MyHandler <  Rack::Tracker::Handler
  ...
end
```

Second we need a method called `#render` which will take care of rendering a
template.

```ruby
def render
  Tilt.new( File.join( File.dirname(__FILE__), 'template', 'my_handler.erb') ).render(self)
end
```

This will render the `template/my_handler.erb` and inject the result into the source. You
can be creative about where the template is stored, but we tend to have them around
our actual handler code.

```erb
<script>
  console.log('my tracker: ' + <%= options.to_json %>)
</script>
```

Lets give it a try! We need to mount our new handler in the `Rack::Tracker` middleware

```ruby
  config.middleware.use(Rack::Tracker) do
    handler MyHandler, { awesome: true }
  end
````

Everything you're passing to the `handler` will be available as `#options` in your
template, so you'll also gain access to the `env`-hash belonging to the current request.

Run your application and make a request, the result of the above template can be
found right before `</head>`. You can change the position in your handler-code:

```ruby
class MyHandler <  Rack::Tracker::Handler
  self.position = :body

  ...
end
```

The snippit will then be rendered right before `</body>`.

To enable the *tracker dsl* functionality in your controllers
you need to implement the `track` class method on your handler:

```ruby
def self.track(name, *event)
  # do something with the event(s) to prepare them for your template
  # and return a hash with a signature like { name => event }
end
```

Checkout the existing handlers in `lib/rack/tracker` for some inspiration. :)


## Contributing

First of all, **thank** you for your help! :green_heart:

If you want a feature implemented, the best way to get it done
is to submit a pull request that implements it.
Tests, readme and changelog entries would be nice.

1. Fork it ( http://github.com/railslove/rack-tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

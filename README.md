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

* [Google Global Site Tag](#google-global)
* [Google Analytics](#google-analytics)
* [Google Adwords Conversion](#google-adwords-conversion)
* [Google Tag Manager](#google-tag-manager)
* [Facebook](#facebook)
* [Visual Website Optimizer (VWO)](#visual-website-optimizer-vwo)
* [GoSquared](#gosquared)
* [Criteo](#criteo)
* [Zanox](#zanox)
* [Hotjar](#hotjar)

## Respecting the Do Not Track (DNT) HTTP header

The Do Not Track (DNT) HTTP header is a HTTP header that requests the server to disable its tracking of the individual user.
This is an opt-out option supported by most browsers. This option is disabled by default and has to be explicitly enabled to indicate the user's request to opt-out.
We believe evey application should respect the user's choice to opt-out and respect this HTTP header.

Since version 2.0.0 rack-tracker respects that request header by default. That means NO tracker is injected IF the DNT header is set to "1".

This option can be overwriten using the `DO_NOT_RESPECT_DNT_HEADER => true` option which must be set on any handler that should ignore the DNT header. (but please think twice before doing that)

### Example on how to not respect the DNT header

```ruby
use Rack::Tracker do
  # this tracker will be injected EVEN IF the DNT header is set to 1
  handler :maybe_a_friendly_tracker, { tracker: 'U-XXXXX-Y', DO_NOT_RESPECT_DNT_HEADER: true }
  # this tracker will NOT be injected if the DNT header is set to 1
  handler :google_analytics, { tracker: 'U-XXXXX-Y' }
end
```

Further reading on the DNT header:

* [Wikipedia Do Not Track](https://en.wikipedia.org/wiki/Do_Not_Track)
* [EFF: Do Not Track](https://www.eff.org/issues/do-not-track)


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

### Google Global

* `:anonymize_ip` -  sets the tracker to remove the last octet from all IP addresses, see https://developers.google.com/analytics/devguides/collection/gtagjs/ip-anonymization for details.
* `:cookie_domain` -  sets the domain name for the [GATC cookies](https://developers.google.com/analytics/devguides/collection/gtagjs/cookies-user-id). If not set its the website domain, with the www. prefix removed.
* `:user_id` -  defines a proc to set the [userId](https://developers.google.com/analytics/devguides/collection/gtagjs/cookies-user-id). Ex: `user_id: lambda { |env| env['rack.session']['user_id'] }` would return the user_id from the session.
* `:link_attribution` - Enables [Enhanced Link Attribution](https://developers.google.com/analytics/devguides/collection/gtagjs/enhanced-link-attribution).
* `:allow_display_features` - Can be used to disable [Display Features](https://developers.google.com/analytics/devguides/collection/gtagjs/display-features).

### Google Analytics

* `:anonymize_ip` -  sets the tracker to remove the last octet from all IP addresses, see https://developers.google.com/analytics/devguides/collection/gajs/methods/gaJSApi_gat?hl=de#_gat._anonymizeIp for details.
* `:cookie_domain` -  sets the domain name for the [GATC cookies](https://developers.google.com/analytics/devguides/collection/analyticsjs/domains#implementation). If not set its the website domain, with the www. prefix removed.
* `:user_id` -  defines a proc to set the [userId](https://developers.google.com/analytics/devguides/collection/analyticsjs/cookies-user-id#user_id). Ex: `user_id: lambda { |env| env['rack.session']['user_id'] }` would return the user_id from the session.
* `:site_speed_sample_rate` - Defines a new sample set size for Site Speed data collection, see https://developers.google.com/analytics/devguides/collection/gajs/methods/gaJSApiBasicConfiguration?hl=de#_gat.GA_Tracker_._setSiteSpeedSampleRate
* `:adjusted_bounce_rate_timeouts` - An array of times in seconds that the tracker will use to set timeouts for adjusted bounce rate tracking. See http://analytics.blogspot.ca/2012/07/tracking-adjusted-bounce-rate-in-google.html for details.
* `:enhanced_link_attribution` - Enables [Enhanced Link Attribution](https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-link-attribution).
* `:advertising` - Enables [Display Features](https://developers.google.com/analytics/devguides/collection/analyticsjs/display-features).
* `:ecommerce` - Enables [Ecommerce Tracking](https://developers.google.com/analytics/devguides/collection/analyticsjs/ecommerce).
* `:enhanced_ecommerce` - Enables [Enhanced Ecommerce Tracking](https://developers.google.com/analytics/devguides/collection/analyticsjs/enhanced-ecommerce)
* `:optimize` - pass [Google Optimize container ID](https://support.google.com/360suite/optimize/answer/6262084#example-combined-snippet) as value (e.g. `optimize: 'GTM-1234'`).
* `:pageview_url_script` - a String containing a custom js script evaluating to the url that shoudl be given to the pageview event. Default to `window.location.pathname + window.location.search`.

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
```

### Google Adwords Conversion

You can configure the handler with default options:
```ruby
config.middleware.use(Rack::Tracker) do
  handler :google_adwords_conversion, { id: 123456,
                                        language: "en",
                                        format: "3",
                                        color: "ffffff",
                                        label: "Conversion label",
                                        currency: "USD" }
end
```

To track adwords conversion from the server side just call the `tracker` method in your controller.
```ruby
  def show
    tracker do |t|
      t.google_adwords_conversion :conversion, { value: 10.0 }
    end
  end
```

You can also specify a different value from default options:
```ruby
  def show
    tracker do |t|
      t.google_adwords_conversion :conversion, { id: 123456,
                                                 language: 'en',
                                                 format: '3',
                                                 color: 'ffffff',
                                                 label: 'Conversion Label',
                                                 value: 10.0 }
    end
  end
```

### Google Tag Manager

Google Tag manager code snippet supports the container id

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :google_tag_manager, { container: 'GTM-XXXXXX' }
  end
```

You can also use an experimental feature to track pageviews under turbolinks, which adds a `pageView` event with a `virtualUrl` of the current url.

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :google_tag_manager, { container: 'GTM-XXXXXX', turbolinks: true }
  end
```

#### Data Layer

GTM supports a [dataLayer](https://developers.google.com/tag-manager/devguide#datalayer) for pushing events as well as variables.

To add events or variables to the dataLayer from the server side, just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.google_tag_manager :push, { price: 'X', another_variable: ['array', 'values'] }
    end
  end
```


### Facebook

* `Facebook Pixel` - adds the [Facebook Pixel](https://www.facebook.com/business/help/952192354843755)

Use in conjunction with the [Facebook Helper](https://developers.facebook.com/docs/facebook-pixel/pixel-helper) to confirm your event fires correctly.

First, add the following to your config:

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :facebook_pixel, { id: 'PIXEL_ID' }
  end
```

#### Dynamic Pixel Configuration

If you need to have different pixel ids e.g. based on the request or serving pages for different accounts, you have the possibility to achieve this by passing a lambda:

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :facebook_pixel, { id: lambda { |env| env['PIXEL_ID'] } }
  end
```

and set the pixel id within the request `env` variable. Here an example on how it can be done in a rails action:

```ruby
  class MyController < ApplicationController
    def show
      request.env['PIXEL_ID'] = 'DYNAMIC_PIXEL_ID'
    end
  end
```

#### Standard Events

To track Standard Events from the server side just call the `tracker` method in your controller.

```ruby
  def show
    tracker do |t|
      t.facebook_pixel :track, { type: 'Purchase', options: { value: 100, currency: 'USD' } }
    end
  end
```

Will result in the following:

```javascript
  fbq("track", "Purchase", {"value":"100.0","currency":"USD"});
```

You can also use non-standard (custom) event names for audience building when you do not need to track or optimize for conversions.

```
  tracker do |t|
    t.facebook_pixel :track_custom, { type: 'FrequentShopper', options: { purchases: 24, category: 'Sport' } }
  end
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
* `set_email: 'email'`

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
    t.zanox :mastertag, { id: "25GHTE9A07DF67DFG90T", category: 'Swimming', amount: '3.50' }
  end
end
```

This will render to the follwing code in the JS:

```
window._zx.push({"id": "25GHTE9A07DF67DFG90T"});
```

and the following variables:
```
zx_category = 'Swimming';
zx_amount = '3.50';
```

#### Conversion tracking

This is an example of a lead event:

```
def show
  tracker do |t|
    t.zanox :lead, { order_i_d: 'DEFC-4321' }
  end
end
```

This is an example of a sale event:

```
def show
  tracker do |t|
    t.zanox :sale, { customer_i_d: '123456', order_i_d: 'DEFC-4321', currency_symbol: 'EUR', total_price: '150.00' }
  end
end
```

### Hotjar

[Hotjar](https://www.hotjar.com/)

```
config.middleware.use(Rack::Tracker) do
  handler :hotjar, { site_id: '1234' }
end
```


### Custom Handlers

Tough we give you handlers for a few tracking services right out of the box, you might
be interested adding support for your custom tracking/analytics service.

Writing a handler is straight forward ;) and there are just a couple of methods that
your class needs to implement.

Start with a plain ruby class that inherits from `Rack::Tracker::Handler`

```ruby
class MyHandler < Rack::Tracker::Handler
  ...
end
```

If you want to customize the rendering of your template, you can overwrite the handlers `#render` method:

```ruby
def render
  Tilt.new( File.join( File.dirname(__FILE__), 'template', 'my_handler.erb') ).render(self)
end
```

> There might be cases where you need to modify the response at multiple places. To do so you
can overwrite the `#inject`-method in your handler. For an example please have a look at the
Google Tag Manager [implementation](https://github.com/railslove/rack-tracker/blob/master/lib/rack/tracker/google_tag_manager/google_tag_manager.rb#L9-L20).

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
class MyHandler < Rack::Tracker::Handler
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


## Please note

Most tracking is done using some kind of Javascript and any tracking data is simply passed on.
Using unvalidated user input in the tracking might result in [XSS issues](https://en.wikipedia.org/wiki/Cross-site_scripting). Do only use secure data.


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

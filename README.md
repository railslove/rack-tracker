# Rack::Tracker

[![Code Climate](https://codeclimate.com/github/railslove/rack-tracker/badges/gpa.svg)](https://codeclimate.com/github/railslove/rack-tracker)

[![Build Status](https://travis-ci.org/railslove/rack-tracker.svg?branch=master)](https://travis-ci.org/railslove/rack-tracker)



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

This will add Google Analytics as a tracking handler. `Rack::Tracker` some with
support for Google Analytics and Facebook. Others might be added in the future
but you can easily write your own handlers.

### Google Analytics

* `:anonymize_ip` -  sets the tracker to remove the last octet from all IP addresses, see https://developers.google.com/analytics/devguides/collection/gajs/methods/gaJSApi_gat?hl=de#_gat._anonymizeIp for details.
* `:cookie_domain` -  sets the domain name for the GATC cookies. Defaults to `auto`.
* `:site_speed_sample_rate` - Defines a new sample set size for Site Speed data collection, see https://developers.google.com/analytics/devguides/collection/gajs/methods/gaJSApiBasicConfiguration?hl=de#_gat.GA_Tracker_._setSiteSpeedSampleRate
* `:adjusted_bounce_rate_timeouts` - An array of times in seconds that the tracker will use to set timeouts for adjusted bounce rate tracking. See http://analytics.blogspot.ca/2012/07/tracking-adjusted-bounce-rate-in-google.html for details.
* `:enhanced_link_attribution` - Enables [Enhanced Link Attribution](https://developers.google.com/analytics/devguides/collection/analyticsjs/advanced#enhancedlink).
* `:advertising` - Enables [Display Features](https://developers.google.com/analytics/devguides/collection/analyticsjs/display-features).
* `:ecommerce` - Enables [Ecommerce Tracking](https://developers.google.com/analytics/devguides/collection/analyticsjs/ecommerce).

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

To load the `ecommerce`-plugin, add some configuration to the middleware initialization,
this is _not_ needed for the above to work, but recommened, so you don't have to
take care of the plugin on your own.

```ruby
  config.middleware.use(Rack::Tracker) do
    handler :google_analytics, { tracker: 'U-XXXXX-Y', ecommerce: true}
  end
````


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

#### Custom Handlers

Tough we give you Google Analytics and Facebook right out of the box, you might
be interested adding support for your custom tracking/analytics service.

Writing a handler is straight forward ;) There are just a couple of methods that
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
can be creative about where the template is stored, we tend to have them around
our actual handler code.

```erb
<script>
  console.log('my tracker: ' + <%= options.to_json %>)
</script>
```

Lets give it a try! We need to mount our new handler in the `Rack::Tracker` middleware

```ruby
  config.middleware.use(Rack::Tracker) do
    handler MyTracker, { awesome: true }
  end
````

Everything you're passing to the `handler` will be availble as `#options` in your
template, You'll also gain access to the `env`-hash belonging to the current request.

Run your application and make a request, the result of the above template can be
found right before `</head>`. You can change the position in your handler-code:

```ruby
class MyHandler <  Rack::Tracker::Handler
  self.position = :body

  ...
end
```

The snippit will then be rendered right before `</body>`.


## Contributing

1. Fork it ( http://github.com/railslove/rack-tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

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

    config.middleware.use(Rack::Tracker) do
      handler Rack::Tracker::GoogleAnalytics, { tracker: 'U-XXXXX-Y' }
    end

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

### Facebook

* `custom_audience_id`


## Server side events

When using `rack-tracker` within a Rails application you can track events from
your controller and the tracking snippit will then populated with this data.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/rack-tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

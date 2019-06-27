# 1.10.0

 * [ENHANCEMENT] Hubspot integration #136 (thx @ChrisCoffey)

# 1.9.0

 * [ENHANCEMENT] Integration for Bing tracking #131 (thx @pcraston)
 * [ENHANCEMENT] Possibility to integrate Google Optimize ID into the allowed tracker options #127 (thx @nachoabad)
 * [ENHANCEMENT] Support for google global events #126 (thx @atd)

# 1.8.0

 * [ENHANCEMENT] Google Global Site Tag: basic integration with support for pageviews to Google global tag #123 (thx @atd)

# 1.7.0

  * [BUGFIX] dup response string in Rack::Tracker#inject to avoid RuntimeError #114 (thx @zpfled)
  * [ENHANCEMENT] Allow to use custom pageview url script for GoogleAnalytics tracker. #119 (thx @Haerezis)

# 1.6.0

  * [BUGFIX] set wildcard to non-greedy for GTM body insertion #107
  * [ENHANCEMENT] Test against Ruby 2.5 #104
  * [ENHANCEMENT] Google Optimize container ID #103
  * [ENHANCEMENT] Allow for dynamic Facebook Pixel options #101

# 1.5.0

  * [ENHANCEMENT] facebook pixel now supports non-standard (custom) event names #93

# 1.4.0

  * [ENHANCEMENT] welcome Hotjar! #90
  * [ENHANCEMENT] experimental turbolinks option for Google Tag manager #88
  * small refactorings
  * benchmark setup

# 1.3.1

  * [BUGFIX] google tag manager now supports body/head tags with attributes #86

# 1.3.0

  * Added handler multiposition support which fixes #80 and

# 1.2.0

  * Added Facebook Pixel support #75
  * Datalayer position fix #72
  * Dropped support for Ruby 1.9
  * Rails 5.x compatibility

# 1.1.0

  * [BREAKING] Google Tag Manager #59
    * change `dataLayer.push` syntax from from `name: 'click', value: 'X'` to just `click: 'X'`
    * this allows to specify a hash with multiple key-value pairs for one push event
    * this will also correctly handle array values (see issue #57)
  * setEmail event for criteo #51 (thx @florianeck)

# 1.0.2

  * Back port deep_stringify_keys! from Rails 4 #55 (thx @jivagoalves)
  * Javascript escape implementation to prevent XSS #54 (thx @fabn)

# 1.0.1

  * [BUGFIX] Fix for adjusted_bounce_rate_timeouts #49 (thx @fabn)
  * [BUGFIX] Do not pass string in mastertag when should be json #47 (thx @berlintam)

# 1.0.0

  * [BUGFIX] breaking API change: set zanox path extension #45 (thx @berlintam)
  * [BUGFIX] Fix Google Analytics pageview command arguments #44 (thx @remiprev)

# 0.4.2

  * [BUGFIX] proper page track when used with turbolink #40 (thx @remiprev @musaffa)

# 0.4.1

  * [ENHANCEMENT] support zanox mastertag and tracking events

# 0.4.0

  * [BUGFIX] store event objects as hashes so they can be safely serialized using JSON (default since rails 4.1) #13
  * added support for Google Analytics User ID feature #15
  * added support for Google adwords conversion #24
  * added support for Google Tag Manager feature #29
  * added support for Google Analytics custom metrics and parameters #31 (thx @mnin)
  * added support for Google Enhanced Ecommerce #32 (thx @mnin)

# 0.3.0

  * [ENHANCEMENT] google analytics cookieDomain renamed to cookie_domain

# 0.2.6

  * [ENHANCEMENT] rails 3 support

# 0.2.5

  * [BUGFIX] stringify google analytics event values to be api compliant

# 0.2.4

  * [ENHANCEMENT] support all the rack versions >= 1.5.2

# 0.2.3

  * [ENHANCEMENT] support all the rails versions >= 4.0.0

# 0.2.2

  * [BUGFIX] the tracker key got lost while merging multiple nested events into env

# 0.2.1

  * [BUGFIX] sending the ecommerce cart was misspelled

# 0.2.0

  * added support for GoSquared
  * added support for Visual Website Optimizer

# 0.1.3

  * [BUGFIX] ecommerce events weren't created properly

# 0.1.2

  * cart is now auto submitted to when ecommerce is turned on and items or transactions are in the queue

# 0.1.1

  * [BUGFIX] return value of the `tracker`-block is kinda unpredictabel, so we skip further processing

# 0.1.0

  * README
  * unified facebook and google handler `#track`-signature (3009b3834ad07caf8818484ddd86d8a0eb128fe5)

# 0.0.4

  * keep events over multiple redirectes
  * allow multiple calls of the same handler in one `tracker` block

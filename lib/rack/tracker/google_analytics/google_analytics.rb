require 'ostruct'

class Rack::Tracker::GoogleAnalytics < Rack::Tracker::Handler
  class Event < OpenStruct
    def event
      {
        hitType: 'event',
        eventCategory: self.event_category,
        eventAction: self.event_action,
        eventLabel: self.event_label,
        eventValue: self.event_value
      }.compact
    end

    def write
      ['send', event].to_json.gsub(/\[|\]/, '')
    end
  end

  class Ecommerce < Struct.new(:action, :payload)
    def write
      [self.action, self.payload.compact].to_json.gsub(/\[|\]/, '')
    end
  end

  def tracker
    options[:tracker].try(:call, env) || options[:tracker]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_analytics.erb') ).render(self)
  end

  def self.track(name, event)
    { name.to_s => [Event.new(event)] }
  end
end

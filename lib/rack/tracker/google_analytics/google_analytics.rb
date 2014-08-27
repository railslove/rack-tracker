class Rack::Tracker::GoogleAnalytics < Rack::Tracker::Handler
  class Event < OpenStruct
    def write
      ['send', event].to_json.gsub(/\[|\]/, '')
    end

    def event
      { hitType: 'event' }.merge(attributes).compact
    end

    def attributes
      Hash[to_h.map { |k,v| ['event' + k.to_s.capitalize, v] }]
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

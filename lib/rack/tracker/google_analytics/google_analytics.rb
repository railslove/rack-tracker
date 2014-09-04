class Rack::Tracker::GoogleAnalytics < Rack::Tracker::Handler
  class Send < OpenStruct
    def initialize(attrs = {})
      attrs.reverse_merge!(type: 'event')
      super
    end

    def write
      ['send', event].to_json.gsub(/\[|\]/, '')
    end

    def event
      { hitType: self.type }.merge(attributes).compact
    end

    def attributes
      Hash[to_h.slice(:category, :action, :label, :value).map { |k,v| [self.type.to_s + k.to_s.capitalize, v] }]
    end
  end

  class Ecommerce < OpenStruct
    def write
      ["ecommerce:#{self.type}", self.to_h.except(:type).compact].to_json.gsub(/\[|\]/, '')
    end
  end

  def tracker
    options[:tracker].try(:call, env) || options[:tracker]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_analytics.erb') ).render(self)
  end

  def ecommerce_events
    events.select{|e| e.kind_of?(Ecommerce) }
  end

  def self.track(name, *event)
    { name.to_s => [Send.new(event.last)] }
  end
end

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
      { hitType: self.type }.merge(attributes.stringify_values).compact
    end

    def attributes
      Hash[to_h.slice(:category, :action, :label, :value).map { |k,v| [self.type.to_s + k.to_s.capitalize, v] }]
    end
  end

  class Ecommerce < OpenStruct
    def write
      ["ecommerce:#{self.type}", self.to_h.except(:type).compact.stringify_values].to_json.gsub(/\[|\]/, '')
    end
  end

  def tracker
    options[:tracker].respond_to?(:call) ? options[:tracker].call(env) : options[:tracker]
  end

  def tracker_options
    @tracker_options ||= begin
      tracker_options = {}

      tracker_options[:cookieDomain] = options[:cookie_domain] if options[:cookie_domain]

      user_id = options[:user_id].call(env) if options[:user_id]
      tracker_options[:userId] = "#{user_id}" if user_id.present?

      tracker_options
    end
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_analytics.erb') ).render(self)
  end

  def ecommerce_events
    events.select{|e| e.kind_of?(Ecommerce) }
  end

  def self.track(name, *event)
    { name.to_s => [const_get(event.first.to_s.capitalize).new(event.last)] }
  end
end

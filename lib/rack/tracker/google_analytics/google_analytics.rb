class Rack::Tracker::GoogleAnalytics < Rack::Tracker::Handler

  ALLOWED_TRACKER_OPTIONS = [:cookie_domain, :user_id]

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

  class EnhancedEcommerce < OpenStruct
    def write
      hash = self.to_h
      label = hash[:label]
      attributes = hash.except(:label, :type).compact.stringify_values

      [
        "ec:#{self.type}",
        label,
        attributes.empty? ? nil : attributes
      ].compact.to_json.gsub(/\[|\]/, '')
    end
  end

  class Ecommerce < OpenStruct
    def write
      attributes = self.to_h.except(:type).compact.stringify_values

      [
        "ecommerce:#{self.type}",
        attributes
      ].to_json.gsub(/\[|\]/, '')
    end
  end

  class Parameter < OpenStruct
    include Rack::Tracker::JavaScriptHelper
    def write
      ['set', self.to_h.to_a].flatten.map { |v| %Q{'#{j(v)}'} }.join ', '
    end
  end

  def tracker
    options[:tracker].respond_to?(:call) ? options[:tracker].call(env) : options[:tracker]
  end

  def tracker_options
    @tracker_options ||= {}.tap do |tracker_options|
      options.slice(*ALLOWED_TRACKER_OPTIONS).each do |key, value|
        if option_value = value.respond_to?(:call) ? value.call(env) : value
          tracker_options[key.to_s.camelize(:lower).to_sym] = option_value.to_s
        end
      end
    end
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_analytics.erb') ).render(self)
  end

  def ecommerce_events
    events.select {|e| e.kind_of?(Ecommerce) }
  end

  def enhanced_ecommerce_events
    events.select {|e| e.kind_of?(EnhancedEcommerce) }
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.classify)] }
  end
end

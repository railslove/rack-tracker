class Rack::Tracker::GoogleAnalytics4 < Rack::Tracker::Handler

  self.allowed_tracker_options = [:cookie_domain, :user_id]

  def initialize(env, options = {})
    super(env, options)
  end

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

  def tracker
    options[:tracker].respond_to?(:call) ? options[:tracker].call(env) : options[:tracker]
  end

  private

  def tracker_option_key(key)
    key.to_s.camelize(:lower).to_sym
  end

  def tracker_option_value(value)
    value.to_s
  end
end

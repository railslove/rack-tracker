class Rack::Tracker::GoogleAnalytics < Rack::Tracker::Handler
  class Event < Struct.new(:category, :action, :label, :value)
    def write
      ['send', { hitType: 'event', eventCategory: self.category, eventAction: self.action, eventLabel: self.label, eventValue: self.value }.compact].to_json.gsub(/\[|\]/, '')
    end
  end

  class Ecommerce < Struct.new(:action, :payload)
    def write
      [self.action, self.payload.compact].to_json.gsub(/\[|\]/, '')
    end
  end

  def events
    env.fetch('tracker', {})['google_analytics'] || []
  end

  def tracker
    options[:tracker].try(:call, env) || options[:tracker]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/google_analytics.erb') ).render(self)
  end

end

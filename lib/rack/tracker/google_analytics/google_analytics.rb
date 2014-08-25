class Rack::Tracker::GoogleAnalytics < Rack::Tracker::Handler
  class Event < Struct.new(:category, :action, :label, :value)
    def write
      { hitType: 'event', eventCategory: self.category, eventAction: self.action, eventLabel: self.label, eventValue: self.value }.select{|k,v| v }.to_json
    end
  end

  def events
    env['tracker.google_analytics.events'] || []
  end

  def tracker
    options[:tracker].try(:call, env) || options[:tracker]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/google_analytics.erb') ).render(self)
  end

end

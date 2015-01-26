class Criteo <  Rack::Tracker::Handler

  TRACKER_OPTIONS = {
    # option/event name => event key name, e.g. { event: 'setSiteType', type: '' }
    set_site_type: :type,
    set_account: :account,
    set_customer_id: :id
  }

  class Event < OpenStruct
    def write
      to_h.to_json
    end
  end

  self.position = :body

  # global events for each tracker instance
  def tracker_events
    @tracker_events ||= begin
      tracker_events = []
      options.slice(*TRACKER_OPTIONS.keys).each do |key, value|
        if option_value = value.respond_to?(:call) ? value.call(env) : value
          tracker_events << Event.new(:event => "#{key}".camelize(:lower),  TRACKER_OPTIONS[key] => "#{option_value}")
        end
      end
      tracker_events
    end
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'criteo.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge(class_name: 'Event')] }
  end
end

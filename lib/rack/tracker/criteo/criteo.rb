class Rack::Tracker::Criteo <  Rack::Tracker::Handler

  TRACKER_EVENTS = {
    # event name => event key name, e.g. { event: 'setSiteType', type: '' }
    set_site_type: :type,
    set_account: :account,
    set_customer_id: :id,
    set_email: :email
  }

  class Event < OpenStruct
    def write
      to_h.to_json
    end
  end

  self.position = :body

  # global events (setSiteType, setAccount, ...) for each tracker instance
  def tracker_events
    @tracker_events ||= [].tap do |tracker_events|
      options.slice(*TRACKER_EVENTS.keys).each do |key, value|
        if option_value = value.respond_to?(:call) ? value.call(env) : value
          tracker_events << Event.new(:event => "#{key}".camelize(:lower),  TRACKER_EVENTS[key] => "#{option_value}")
        end
      end
    end
  end

  def self.track(name, event_name, event_args = {})
    { name.to_s => [{ 'class_name' => 'Event', 'event' => event_name.to_s.camelize(:lower) }.merge(event_args)] }
  end
end

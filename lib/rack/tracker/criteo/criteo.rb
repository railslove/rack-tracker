class Criteo <  Rack::Tracker::Handler
  class Event < OpenStruct
    def write
      to_h.to_json
    end
  end

  self.position = :body

  def tracker_options
    @tracker_options ||= begin
      tracker_options = {}

      user_id = options[:user_id].call(env) if options[:user_id]
      tracker_options[:user_id] = "#{user_id}" if user_id.present?

      site_type = options[:site_type].call(env) if options[:site_type]
      tracker_options[:site_type] = "#{site_type}" if site_type.present?

      tracker_options
    end
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'criteo.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge(class_name: 'Event')] }
  end
end

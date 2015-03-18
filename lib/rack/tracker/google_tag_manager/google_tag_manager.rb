class Rack::Tracker::GoogleTagManager < Rack::Tracker::Handler

  ALLOWED_TRACKER_OPTIONS = [:cookie_domain, :user_id]

  class Push < OpenStruct

    def write
      "'#{event[:name]}': '#{event[:value]}'"
    end

    def event
      attributes.stringify_values.compact
    end

    def attributes
      to_h.slice(:name, :value)
    end
  end

  def tracker
    options[:tracker].respond_to?(:call) ? options[:tracker].call(env) : options[:tracker]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_tag_manager.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end

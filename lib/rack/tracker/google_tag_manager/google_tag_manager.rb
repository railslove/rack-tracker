class Rack::Tracker::GoogleTagManager < Rack::Tracker::Handler

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

  # It is strongly recommended to put the google_tag_manager snippet only in the body tag
  # https://developers.google.com/tag-manager/quickstart
  self.position body: :prepend

  def container
    options[:container].respond_to?(:call) ? options[:container].call(env) : options[:container]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_tag_manager.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end

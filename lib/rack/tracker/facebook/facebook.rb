class Rack::Tracker::Facebook < Rack::Tracker::Handler
  class Event < OpenStruct
    def write
      options.present? ? type_to_json << options_to_json : type_to_json
    end

    private

    def type_to_json
      self.type.to_json
    end

    def options_to_json
      ", #{self.options.to_json}"
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/facebook.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => 'Event')] }
  end
end

class Rack::Tracker::Facebook < Rack::Tracker::Handler
  class Event < OpenStruct
    def write
      ['track', self.id, to_h.except(:id).compact].to_json
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/facebook.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.deep_stringify_keys.merge('class_name' => 'Event')] }
  end

end

class Rack::Tracker::Facebook < Rack::Tracker::Handler
  class Event < OpenStruct
    def write
      ['track', self.id, to_h.except(:id).compact].to_json
    end
  end

  self.position = :body

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => 'Event')] }
  end

end

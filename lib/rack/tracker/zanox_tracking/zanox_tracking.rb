class Rack::Tracker::ZanoxTracking < Rack::Tracker::Handler

  class Event < OpenStruct
    def write
      to_h.map do |k,v|
        "#{k.camelize}=[[#{v}]]"
      end.join('&')
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'zanox_mastertag.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => 'Event')] }
  end
end
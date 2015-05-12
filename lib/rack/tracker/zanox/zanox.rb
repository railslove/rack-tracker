class Rack::Tracker::Zanox < Rack::Tracker::Handler

  class Mastertag < OpenStruct
  end

  class Track < OpenStruct
    def write
      to_h.map do |k,v|
        "#{k.camelize}=[[#{v}]]"
      end.join('&')
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'zanox.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end
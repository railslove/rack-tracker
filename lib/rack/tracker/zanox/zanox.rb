class Rack::Tracker::Zanox < Rack::Tracker::Handler

  class Mastertag < OpenStruct
  end

  class Track < OpenStruct
    # Example: OrderID=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[23.40]]
    def write
      to_h.map do |k,v|
        "#{k.camelize}=[[#{v}]]"
      end.join('&')
    end
  end

  self.position = :body

  def mastertag
    # First event should be stronger, e.g. one signs up and gets redirected to homepage
    # "sign up" should be tracked instead of "view homepage"
    events.select{ |event| event.class.name == 'Mastertag' }.first
  end

  def tracking_events
    events.select{ |event| event.class.name == 'Track' }
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'zanox.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end

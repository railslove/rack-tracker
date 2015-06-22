class Rack::Tracker::Zanox < Rack::Tracker::Handler

  # name of the handler
  # everything after is passed as options
  class Mastertag < OpenStruct
  end

  class Track < OpenStruct
    # Example: OrderID=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[23.40]]
    # url_param gets passed into the url, but should not be one of main parameters set to zanox
    def write
      events = to_h.delete_if { |k,v| k == :path_extension}
      events.map do |k,v|
        "#{k.to_s.camelize}=[[#{v}]]"
      end.join('&')
    end

    def path_extension
      to_h[:path_extension]
    end
  end

  self.position = :body

  def mastertag
    # First event should be stronger, e.g. one signs up and gets redirected to homepage
    # "sign up" should be tracked instead of "view homepage"
    events.select{ |event| event.class.to_s.demodulize == 'Mastertag' }.first
  end

  def tracking_events
    events.select{ |event| event.class.to_s.demodulize == 'Track' }
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'zanox.erb') ).render(self)
  end

  # this is called with additional arguments to t.zanox
  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end

class Rack::Tracker::Zanox < Rack::Tracker::Handler

  # name of the handler
  # everything after is passed as options
  class Mastertag < OpenStruct

    def write
      to_h.except(:id).map do |k,v|
        "var zx_#{k} = #{v.to_json};"
      end.join("\n")
    end
  end

  class Lead < OpenStruct
    # Example: OrderID=[[DEFC-4321]]&CurrencySymbol=[[EUR]]&TotalPrice=[[23.40]]

    def write
      to_h.map do |k,v|
        "#{k.to_s.camelize}=[[#{v}]]"
      end.join('&')
    end
  end

  class Sale < OpenStruct
    def write
      to_h.map do |k,v|
        "#{k.to_s.camelize}=[[#{v}]]"
      end.join('&')
    end
  end

  self.position = :body

  def mastertag
    # First event should be stronger, e.g. one signs up and gets redirected to homepage
    # "sign up" should be tracked instead of "view homepage"
    events.select{ |event| event.class.to_s.demodulize == 'Mastertag' }.first
  end

  def lead_events
    events.select{ |event| event.class.to_s.demodulize == 'Lead' }
  end

  def sale_events
    events.select{ |event| event.class.to_s.demodulize == 'Sale' }
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'zanox.erb') ).render(self)
  end

  # this is called with additional arguments to t.zanox
  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end

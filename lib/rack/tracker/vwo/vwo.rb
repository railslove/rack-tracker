class Rack::Tracker::Vwo <  Rack::Tracker::Handler
  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'vwo.erb') ).render(self)
  end
end

class Rack::Tracker::Vwo <  Rack::Tracker::Handler
  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'vwo.erb') ).render(self)
  end

  def default_positions
    { before_head_close: :render }
  end
end

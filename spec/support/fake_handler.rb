class TrackAllTheThings < Rack::Tracker::Handler
  def render
    Tilt.new( File.join( File.dirname(__FILE__), '../fixtures/track_all_the_things.erb') ).render(self)
  end

  def self.track(name, event)
    { name.to_s => event }
  end

  def track_me
    session = env['rack.session'] ||= {}
    session['tracker']['track_all_the_things']
  end
end


class AnotherHandler < Rack::Tracker::Handler
  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), '../fixtures/another_handler.erb') ).render(self)
  end

  def self.track(name, event)
    { name.to_s => event }
  end

  def track_me
    session = env['rack.session'] ||= {}
    session['tracker']['another_handler']
  end
end

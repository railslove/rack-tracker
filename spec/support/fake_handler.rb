class TrackAllTheThings < Rack::Tracker::Handler
  def render
    Tilt.new( File.join( File.dirname(__FILE__), '../fixtures/track_all_the_things.erb') ).render(self)
  end

  def self.track(name, event)
    { name.to_s => event }
  end

  def track_me
    env['tracker']['track_all_the_things']
  end

  def default_positions
    {
      before_head_close: :render
    }
  end
end


class AnotherHandler < Rack::Tracker::Handler

  def render
    Tilt.new( File.join( File.dirname(__FILE__), '../fixtures/another_handler.erb') ).render(self)
  end

  def self.track(name, event)
    { name.to_s => event }
  end

  def track_me
    env['tracker']['another_handler']
  end

  def default_positions
    { before_body_close: :render }
  end
end

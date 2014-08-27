class Rack::Tracker::Facebook < Rack::Tracker::Handler
  class Event < OpenStruct
    attr_reader :id
    def initialize(id, attributes = {})
      @id = id
      super(attributes)
    end

    def write
      ['track', @id, to_h.compact].to_json
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/facebook.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [Event.new(*event)] }
  end

end

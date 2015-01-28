class Rack::Tracker::Metrigo < Rack::Tracker::Handler
  class Event < OpenStruct
    def initialize(args)
      args[:arguments] ||= {}
      super
    end

    def write
      "DELIVERY.DataLogger.#{function_name}(#{arguments.to_json})"
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/metrigo.erb') ).render(self)
  end

  # merges shop_id into all Event objects
  def events
    super.map do |event|
      event.arguments.merge!(shop_id: options[:shop_id])
      event
    end
  end

  def self.track(name, *event)
    { name.to_s => [{ class_name: 'Event', function_name: event[0].to_s.camelize(:lower), arguments: event[1] }] }
  end

end

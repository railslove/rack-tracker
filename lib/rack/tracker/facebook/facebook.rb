class Rack::Tracker::Facebook < Rack::Tracker::Handler
  class Event < OpenStruct
    def write
      ['track', self.id, to_h.except(:id).compact].to_json
    end
  end

  self.position = :body

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template/facebook.erb') ).render(self)
  end

  def custom_audience
    if options[:custom_audience].respond_to?(:call)
      options[:custom_audience].call(env)
    else
      options[:custom_audience]
    end
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => 'Event')] }
  end

end

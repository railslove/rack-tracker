class Rack::Tracker::GoSquared < Rack::Tracker::Handler
  class VisitorName < OpenStruct
    def write
      ['set', 'visitorName', self.name].to_json.gsub(/\[|\]/, '')
    end
  end

  class VisitorInfo < OpenStruct
    def write
      ['set', 'visitor', to_h].to_json.gsub(/\[|\]/, '')
    end
  end

  def tracker
    options[:tracker]
  end

  def trackers
    options[:trackers]
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'go_squared.erb') ).render(self)
  end

  def visitor_name
    events.select{|e| e.kind_of?(VisitorName) }.first
  end

  def visitor_info
    events.select{|e| e.kind_of?(VisitorInfo) }.first
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.classify)] }
  end
end

class Rack::Tracker::GoogleAdwordsConversion < Rack::Tracker::Handler

  class Conversion < OpenStruct
  end

  def render
    Tilt.new( File.join( File.dirname(__FILE__), 'template', 'google_adwords_conversion.erb') ).render(self)
  end

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end

  def default_positions
    { before_body_close: :render }
  end
end

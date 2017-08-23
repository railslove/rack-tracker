class Rack::Tracker::GoogleAdwordsConversion < Rack::Tracker::Handler

  class Conversion < OpenStruct
  end

  self.position = :body

  def self.track(name, *event)
    { name.to_s => [event.last.merge('class_name' => event.first.to_s.capitalize)] }
  end
end

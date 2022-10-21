class Rack::Tracker::TiktokPixel < Rack::Tracker::Handler
  self.position = :body
  self.allowed_tracker_options = [:id]

end

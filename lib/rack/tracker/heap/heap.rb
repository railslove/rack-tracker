class Rack::Tracker::Heap < Rack::Tracker::Handler
  self.allowed_tracker_options = [:user_id, :reset_identity]
end

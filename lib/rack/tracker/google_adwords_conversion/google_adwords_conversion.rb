# frozen_string_literal: true

class Rack::Tracker::GoogleAdwordsConversion < Rack::Tracker::Handler
  class Conversion < OpenStruct
  end

  self.position = :body
end

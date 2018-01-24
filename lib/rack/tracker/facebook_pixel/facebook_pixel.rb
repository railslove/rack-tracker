class Rack::Tracker::FacebookPixel < Rack::Tracker::Handler
  self.position = :body
  self.allowed_tracker_options = [:id]

  class Event < OpenStruct
    def write
      options.present? ? type_to_json << options_to_json : type_to_json
    end

    private

    def type_to_json
      type.to_json
    end

    def options_to_json
      ", #{options.to_json}"
    end
  end

  class Track < Event
    def name
      'track'
    end
  end

  class TrackCustom < Event
    def name
      'trackCustom'
    end
  end
end

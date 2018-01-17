class Rack::Tracker::FacebookPixel < Rack::Tracker::Handler
  self.position = :body

  def tracker_options
    @_tracker_options ||= {}.tap do |tracker_options|
      options.each do |key, value|
        if option_value = value.respond_to?(:call) ? value.call(env) : value
          tracker_options[key] = option_value
        end
      end
    end
  end

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

class Rack::Tracker::GoogleGlobal < Rack::Tracker::Handler
  self.allowed_tracker_options = [:cookie_domain, :user_id,
    :link_attribution, :allow_display_features, :anonymize_ip,
    :custom_map]

  class Page < OpenStruct
    def params
      Hash[to_h.slice(:title, :location, :path).map { |key, value| ["page_#{key}", value] }]
    end
  end

  def pages
    events # TODO: Filter pages after Event is implemented
  end

  def trackers
    options[:trackers].map { |tracker|
      tracker[:id].respond_to?(:call) ? tracker.merge(id: tracker[:id].call(env)) : tracker
    }.reject { |tracker| tracker[:id].nil? }
  end

  def set_options
    @_set_options ||= build_set_options
  end

  private

  def build_set_options
    value = options[:set]
    value.respond_to?(:call) ? value.call(env) : value
  end
end
